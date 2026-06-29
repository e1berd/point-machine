import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

import '../core/pairing.dart';

class NfcPairing {
  const NfcPairing();

  static const mimeType =
      'application/vnd.tech.hammerhead.mesh-market.pairing+json';
  static const _channel = MethodChannel(
    'tech.hammerhead.mesh_market/nfc_pairing',
  );

  static Future<bool> isAvailable() async {
    try {
      return await NfcManager.instance.isAvailable();
    } on Object {
      return false;
    }
  }

  Future<PairingPayload> shareAndRead(PairingPayload self) async {
    await _startHce(self).catchError((_) => false);
    await _startNdefPush(self).catchError((_) => false);
    try {
      return await read();
    } finally {
      await _stopNdefPush().catchError((_) {});
      await _stopHce().catchError((_) {});
    }
  }

  Future<PairingPayload> read() async {
    final completer = Completer<PairingPayload>();
    await NfcManager.instance.startSession(
      pollingOptions: const {NfcPollingOption.iso14443},
      onDiscovered: (tag) async {
        final payload = await _readTag(tag);
        if (payload != null && !completer.isCompleted) {
          completer.complete(payload);
          await NfcManager.instance.stopSession();
        }
      },
    );
    try {
      return await completer.future.timeout(const Duration(seconds: 30));
    } on Object {
      await NfcManager.instance.stopSession().catchError((_) {});
      rethrow;
    }
  }

  Future<bool> _startNdefPush(PairingPayload payload) async {
    final ok = await _channel.invokeMethod<bool>('startNdefPush', {
      'mimeType': mimeType,
      'payload': payload.encode(),
    });
    return ok ?? false;
  }

  Future<void> _stopNdefPush() => _channel.invokeMethod<void>('stopNdefPush');

  Future<bool> _startHce(PairingPayload payload) async {
    final ok = await _channel.invokeMethod<bool>('startHce', {
      'payload': payload.encode(),
    });
    return ok ?? false;
  }

  Future<void> _stopHce() => _channel.invokeMethod<void>('stopHce');

  Future<PairingPayload?> _readTag(NfcTag tag) async {
    final hcePayload = await _readHce(tag);
    if (hcePayload != null) return hcePayload;
    return _extractNdef(tag);
  }

  Future<PairingPayload?> _readHce(NfcTag tag) async {
    final isoDep = IsoDep.from(tag);
    if (isoDep == null) return null;
    try {
      final selected = await isoDep.transceive(data: _selectAidApdu());
      if (!_isSuccess(selected)) return null;

      final info = await isoDep.transceive(
        data: Uint8List.fromList([0x80, 0x10, 0, 0, 4]),
      );
      if (!_isSuccess(info) || info.length < 6) return null;
      final length =
          (info[0] << 24) | (info[1] << 16) | (info[2] << 8) | info[3];
      if (length <= 0 || length > 4096) return null;

      final bytes = <int>[];
      while (bytes.length < length) {
        final offset = bytes.length;
        final chunkSize = (length - offset).clamp(1, 240);
        final chunk = await isoDep.transceive(
          data: Uint8List.fromList([
            0x80,
            0x20,
            (offset >> 8) & 0xff,
            offset & 0xff,
            chunkSize,
          ]),
        );
        if (!_isSuccess(chunk) || chunk.length <= 2) return null;
        bytes.addAll(chunk.take(chunk.length - 2));
      }
      return PairingPayload.decode(utf8.decode(bytes));
    } on Object {
      return null;
    }
  }

  Uint8List _selectAidApdu() {
    const aid = [0xf0, 0x48, 0x4d, 0x50, 0x41, 0x49, 0x52];
    return Uint8List.fromList([
      0x00,
      0xa4,
      0x04,
      0x00,
      aid.length,
      ...aid,
      0x00,
    ]);
  }

  bool _isSuccess(Uint8List response) =>
      response.length >= 2 &&
      response[response.length - 2] == 0x90 &&
      response[response.length - 1] == 0x00;

  PairingPayload? _extractNdef(NfcTag tag) {
    final message = Ndef.from(tag)?.cachedMessage;
    if (message == null) return null;
    for (final record in message.records) {
      final json = _recordJson(record);
      if (json == null) continue;
      try {
        return PairingPayload.decode(json);
      } on Object {
        continue;
      }
    }
    return null;
  }

  String? _recordJson(NdefRecord record) {
    if (_isPairingMime(record)) {
      return _text(record.payload);
    }
    return _json(_text(record.payload));
  }

  bool _isPairingMime(NdefRecord record) {
    if (record.typeNameFormat != NdefTypeNameFormat.media) return false;
    final type = ascii.decode(record.type, allowInvalid: true).toLowerCase();
    return type == mimeType;
  }

  String _text(Uint8List payload) => utf8.decode(payload, allowMalformed: true);

  String? _json(String text) {
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start < 0 || end <= start) return null;
    return text.substring(start, end + 1);
  }
}
