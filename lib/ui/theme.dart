import 'package:flutter/material.dart';

const _seed = Colors.deepPurple;

ThemeData pointTheme(Brightness brightness, [ColorScheme? dynamicScheme]) {
  final scheme = dynamicScheme ??
      ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
  return ThemeData(
    colorScheme: scheme,
    brightness: scheme.brightness,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      centerTitle: false,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainer,
      indicatorColor: scheme.secondaryContainer,
    ),
  );
}
