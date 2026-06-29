import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:permission_handler/permission_handler.dart';

import 'desktop_tray.dart';
import 'sync_background.dart';

bool get _isDesktop =>
    Platform.isLinux || Platform.isMacOS || Platform.isWindows;

bool get _isMobile => Platform.isAndroid || Platform.isIOS;

Future<DesktopTray?> setupBackground({
  required Future<void> Function() onQuit,
  required bool syncInBackground,
}) async {
  if (_isDesktop) {
    final tray = DesktopTray(
      iconPath: Platform.isWindows ? 'assets/tray.ico' : 'assets/tray.png',
      onQuit: onQuit,
    );
    try {
      await tray.setup();
    } on Object catch (error, stack) {
      debugPrint('[pm.tray] setup failed: $error\n$stack');
    }
    return tray;
  }

  if (_isMobile) {
    await _initBackgroundService(syncInBackground: syncInBackground);
  }

  return null;
}

Future<void> _initBackgroundService({required bool syncInBackground}) async {
  if (Platform.isAndroid) {
    try {
      await Permission.notification.request();
    } on Object catch (error, stack) {
      debugPrint(
        '[pm.bg] notification permission request failed: $error\n$stack',
      );
    }
    try {
      await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
        Permission.nearbyWifiDevices,
      ].request();
    } on Object catch (error, stack) {
      debugPrint(
        '[pm.bg] connectivity permission request failed: $error\n$stack',
      );
    }
  }

  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: syncBackgroundEntry,
      autoStart: syncInBackground,
      isForegroundMode: true,
      foregroundServiceNotificationId: 888,
      initialNotificationTitle: 'Mesh Market',
      initialNotificationContent: 'Sync is active',
    ),
    iosConfiguration: IosConfiguration(
      autoStart: syncInBackground,
      onForeground: syncBackgroundEntry,
      onBackground: (_) => true,
    ),
  );

  if (!syncInBackground) await stopBackgroundService();
}

Future<void> startBackgroundService() async {
  if (!_isMobile) return;
  final service = FlutterBackgroundService();
  final isRunning = await service.isRunning();
  if (!isRunning) {
    await service.startService();
  }
}

Future<void> stopBackgroundService() async {
  if (!_isMobile) return;
  final service = FlutterBackgroundService();
  final isRunning = await service.isRunning();
  if (isRunning) {
    service.invoke('stopService');
  }
}

Future<void> updateBackgroundNotification({
  required String title,
  required String content,
}) async {
  if (!_isMobile) return;
  final service = FlutterBackgroundService();
  final isRunning = await service.isRunning();
  if (isRunning) {
    service.invoke('updateNotification', {'title': title, 'content': content});
  }
}
