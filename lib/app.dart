import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'state/app_providers.dart';
import 'ui/home_shell.dart';
import 'ui/theme.dart';

class PointMachineApp extends ConsumerWidget {
  const PointMachineApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeConfig = ref.watch(
      configProvider.select(
        (c) => (mode: c.themeMode, schemeId: c.themeSchemeId),
      ),
    );
    return MaterialApp(
      title: 'point-machine',
      theme: pointTheme(.light, themeConfig.schemeId),
      darkTheme: pointTheme(.dark, themeConfig.schemeId),
      themeMode: themeConfig.mode,
      themeAnimationDuration: const Duration(milliseconds: 220),
      themeAnimationCurve: Easing.emphasizedDecelerate,
      debugShowCheckedModeBanner: false,
      home: const HomeShell(),
    );
  }
}
