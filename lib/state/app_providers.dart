import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config.dart';

final configProvider = NotifierProvider<ConfigNotifier, AppConfig>(
  ConfigNotifier.new,
);

class ConfigNotifier extends Notifier<AppConfig> {
  @override
  AppConfig build() => const AppConfig();

  void setThemeMode(ThemeMode mode) => state = state.copyWith(themeMode: mode);

  void setThemeScheme(String id) => state = state.copyWith(themeSchemeId: id);

  void toggleLanDiscovery(bool value) =>
      state = state.copyWith(lanDiscovery: value);

  void toggleDhtDiscovery(bool value) =>
      state = state.copyWith(dhtDiscovery: value);

  void toggleBackground(bool value) =>
      state = state.copyWith(syncInBackground: value);

  void addIceServer(IceServer server) =>
      state = state.copyWith(iceServers: [...state.iceServers, server]);

  void removeIceServer(int index) => state = state.copyWith(
    iceServers: [...state.iceServers]..removeAt(index),
  );
}
