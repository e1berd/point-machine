import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'platform/background.dart';
import 'platform/desktop_lifecycle.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  final tray = await setupBackground(onQuit: () async {});
  runApp(const ProviderScope(child: PointMachineApp()));
  if (tray != null) {
    attachDesktopLifecycle(tray, startHidden: args.contains('--hidden'));
  }
}
