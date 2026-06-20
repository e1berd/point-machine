import 'package:flutter/material.dart' show ThemeMode;

class IceServer {
  const IceServer({required this.url, this.username, this.credential});

  final String url;
  final String? username;
  final String? credential;

  bool get isTurn => url.startsWith('turn:') || url.startsWith('turns:');

  Map<String, dynamic> toWebRtc() => {
        'urls': url,
        if (username != null) 'username': username,
        if (credential != null) 'credential': credential,
      };
}

const defaultIceServers = [
  IceServer(url: 'stun:stun.l.google.com:19302'),
];

class AppConfig {
  const AppConfig({
    this.themeMode = .system,
    this.iceServers = defaultIceServers,
    this.lanDiscovery = true,
    this.dhtDiscovery = true,
    this.syncInBackground = true,
  });

  final ThemeMode themeMode;
  final List<IceServer> iceServers;
  final bool lanDiscovery;
  final bool dhtDiscovery;
  final bool syncInBackground;

  AppConfig copyWith({
    ThemeMode? themeMode,
    List<IceServer>? iceServers,
    bool? lanDiscovery,
    bool? dhtDiscovery,
    bool? syncInBackground,
  }) =>
      AppConfig(
        themeMode: themeMode ?? this.themeMode,
        iceServers: iceServers ?? this.iceServers,
        lanDiscovery: lanDiscovery ?? this.lanDiscovery,
        dhtDiscovery: dhtDiscovery ?? this.dhtDiscovery,
        syncInBackground: syncInBackground ?? this.syncInBackground,
      );
}
