import 'dart:ui';

import 'package:flutter/widgets.dart';

import 'desktop_tray.dart';

AppLifecycleListener attachDesktopLifecycle(
  DesktopTray tray, {
  bool startHidden = false,
}) {
  if (startHidden) {
    WidgetsBinding.instance.addPostFrameCallback((_) => tray.hideToTray());
  }
  return AppLifecycleListener(
    onExitRequested: () async {
      tray.hideToTray();
      return AppExitResponse.cancel;
    },
  );
}
