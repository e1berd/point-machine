import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';

import '../crypto/codec.dart';

class DeviceIdentity {
  DeviceIdentity({
    required this.id,
    required this.signing,
    required this.agreement,
    required this.signingPublicKey,
    required this.agreementPublicKey,
  });

  final String id;
  final SimpleKeyPair signing;
  final SimpleKeyPair agreement;
  final SimplePublicKey signingPublicKey;
  final SimplePublicKey agreementPublicKey;

  Future<List<int>> sign(List<int> message) async {
    final signature = await Ed25519().sign(message, keyPair: signing);
    return signature.bytes;
  }
}

class IdentityService {
  IdentityService(this.file);

  final File file;

  Future<DeviceIdentity> loadOrCreate() async {
    final seeds = await _read() ?? await _create();
    final signing = await Ed25519().newKeyPairFromSeed(seeds.signing);
    final agreement = await X25519().newKeyPairFromSeed(seeds.agreement);
    final signingPublicKey = await signing.extractPublicKey();
    final agreementPublicKey = await agreement.extractPublicKey();
    final digest = await Sha256().hash(signingPublicKey.bytes);
    return DeviceIdentity(
      id: base32Encode(digest.bytes.sublist(0, 20)),
      signing: signing,
      agreement: agreement,
      signingPublicKey: signingPublicKey,
      agreementPublicKey: agreementPublicKey,
    );
  }

  Future<_Seeds?> _read() async {
    if (!await file.exists()) return null;
    final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    return _Seeds(
      base64Decode(json['signing'] as String),
      base64Decode(json['agreement'] as String),
    );
  }

  Future<_Seeds> _create() async {
    final signing = await Ed25519().newKeyPair();
    final agreement = await X25519().newKeyPair();
    final seeds = _Seeds(
      await signing.extractPrivateKeyBytes(),
      await agreement.extractPrivateKeyBytes(),
    );
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode({
      'signing': base64Encode(seeds.signing),
      'agreement': base64Encode(seeds.agreement),
    }));
    return seeds;
  }
}

class _Seeds {
  _Seeds(this.signing, this.agreement);

  final List<int> signing;
  final List<int> agreement;
}
