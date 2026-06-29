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

const defaultIceServers = [IceServer(url: 'stun:stun.l.google.com:19302')];

enum SyncScheduleUnit { days, months }

class AppConfig {
  const AppConfig({
    this.themeMode = .system,
    this.themeSchemeId = 'violet',
    this.iceServers = defaultIceServers,
    this.lanDiscovery = true,
    this.dhtDiscovery = true,
    this.portMapping = true,
    this.peerRelay = true,
    this.holePunch = true,
    this.bluetoothDiscovery = true,
    this.wifiDirectDiscovery = false,
    this.multipeerDiscovery = false,
    this.wifiAwareDiscovery = false,
    this.hotspotFallback = false,
    this.nfcPairing = false,
    this.syncInBackground = true,
    this.syncNow = true,
    this.scheduleEnabled = false,
    this.scheduleUnit = SyncScheduleUnit.days,
    this.scheduleEvery = 1,
    this.scheduleAnchorDay = 0,
    this.scheduleTimes = const [720],
    this.scheduleWindowMinutes = 30,
    this.activityLogPath,
    this.localeCode,
  });

  final ThemeMode themeMode;
  final String themeSchemeId;
  final List<IceServer> iceServers;
  final bool lanDiscovery;
  final bool dhtDiscovery;
  final bool portMapping;
  final bool peerRelay;
  final bool holePunch;
  final bool bluetoothDiscovery;
  final bool wifiDirectDiscovery;
  final bool multipeerDiscovery;
  final bool wifiAwareDiscovery;
  final bool hotspotFallback;
  final bool nfcPairing;
  final bool syncInBackground;
  final bool syncNow;
  final bool scheduleEnabled;
  final SyncScheduleUnit scheduleUnit;
  final int scheduleEvery;
  final int scheduleAnchorDay;
  final List<int> scheduleTimes;
  final int scheduleWindowMinutes;
  final String? activityLogPath;
  final String? localeCode;

  AppConfig copyWith({
    ThemeMode? themeMode,
    String? themeSchemeId,
    List<IceServer>? iceServers,
    bool? lanDiscovery,
    bool? dhtDiscovery,
    bool? portMapping,
    bool? peerRelay,
    bool? holePunch,
    bool? bluetoothDiscovery,
    bool? wifiDirectDiscovery,
    bool? multipeerDiscovery,
    bool? wifiAwareDiscovery,
    bool? hotspotFallback,
    bool? nfcPairing,
    bool? syncInBackground,
    bool? syncNow,
    bool? scheduleEnabled,
    SyncScheduleUnit? scheduleUnit,
    int? scheduleEvery,
    int? scheduleAnchorDay,
    List<int>? scheduleTimes,
    int? scheduleWindowMinutes,
    String? activityLogPath,
    String? localeCode,
  }) => AppConfig(
    themeMode: themeMode ?? this.themeMode,
    themeSchemeId: themeSchemeId ?? this.themeSchemeId,
    iceServers: iceServers ?? this.iceServers,
    lanDiscovery: lanDiscovery ?? this.lanDiscovery,
    dhtDiscovery: dhtDiscovery ?? this.dhtDiscovery,
    portMapping: portMapping ?? this.portMapping,
    peerRelay: peerRelay ?? this.peerRelay,
    holePunch: holePunch ?? this.holePunch,
    bluetoothDiscovery: bluetoothDiscovery ?? this.bluetoothDiscovery,
    wifiDirectDiscovery: wifiDirectDiscovery ?? this.wifiDirectDiscovery,
    multipeerDiscovery: multipeerDiscovery ?? this.multipeerDiscovery,
    wifiAwareDiscovery: wifiAwareDiscovery ?? this.wifiAwareDiscovery,
    hotspotFallback: hotspotFallback ?? this.hotspotFallback,
    nfcPairing: nfcPairing ?? this.nfcPairing,
    syncInBackground: syncInBackground ?? this.syncInBackground,
    syncNow: syncNow ?? this.syncNow,
    scheduleEnabled: scheduleEnabled ?? this.scheduleEnabled,
    scheduleUnit: scheduleUnit ?? this.scheduleUnit,
    scheduleEvery: scheduleEvery ?? this.scheduleEvery,
    scheduleAnchorDay: scheduleAnchorDay ?? this.scheduleAnchorDay,
    scheduleTimes: scheduleTimes ?? this.scheduleTimes,
    scheduleWindowMinutes: scheduleWindowMinutes ?? this.scheduleWindowMinutes,
    activityLogPath: activityLogPath ?? this.activityLogPath,
    localeCode: localeCode ?? this.localeCode,
  );

  Map<String, dynamic> toJson() => {
    'themeMode': themeMode.index,
    'themeSchemeId': themeSchemeId,
    'iceServers': iceServers
        .map(
          (s) => {
            'url': s.url,
            if (s.username != null) 'username': s.username,
            if (s.credential != null) 'credential': s.credential,
          },
        )
        .toList(),
    'lanDiscovery': lanDiscovery,
    'dhtDiscovery': dhtDiscovery,
    'portMapping': portMapping,
    'peerRelay': peerRelay,
    'holePunch': holePunch,
    'bluetoothDiscovery': bluetoothDiscovery,
    'wifiDirectDiscovery': wifiDirectDiscovery,
    'multipeerDiscovery': multipeerDiscovery,
    'wifiAwareDiscovery': wifiAwareDiscovery,
    'hotspotFallback': hotspotFallback,
    'nfcPairing': nfcPairing,
    'syncInBackground': syncInBackground,
    'syncNow': syncNow,
    'scheduleEnabled': scheduleEnabled,
    'scheduleUnit': scheduleUnit.name,
    'scheduleEvery': scheduleEvery,
    'scheduleAnchorDay': scheduleAnchorDay,
    'scheduleTimes': scheduleTimes,
    'scheduleWindowMinutes': scheduleWindowMinutes,
    if (activityLogPath != null) 'activityLogPath': activityLogPath,
    if (localeCode != null) 'localeCode': localeCode,
  };

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    final legacyStart = json['scheduleStart'] as int? ?? 720;
    final legacyEnd = json['scheduleEnd'] as int? ?? 750;
    final rawTimes = json['scheduleTimes'] as List<dynamic>?;
    return AppConfig(
      themeMode: ThemeMode.values[json['themeMode'] as int? ?? 0],
      themeSchemeId: json['themeSchemeId'] as String? ?? 'violet',
      iceServers:
          (json['iceServers'] as List<dynamic>?)
              ?.map(
                (s) => IceServer(
                  url: s['url'] as String,
                  username: s['username'] as String?,
                  credential: s['credential'] as String?,
                ),
              )
              .toList() ??
          defaultIceServers,
      lanDiscovery: json['lanDiscovery'] as bool? ?? true,
      dhtDiscovery: json['dhtDiscovery'] as bool? ?? true,
      portMapping: json['portMapping'] as bool? ?? true,
      peerRelay: json['peerRelay'] as bool? ?? true,
      holePunch: json['holePunch'] as bool? ?? true,
      bluetoothDiscovery: json['bluetoothDiscovery'] as bool? ?? true,
      wifiDirectDiscovery: json['wifiDirectDiscovery'] as bool? ?? false,
      multipeerDiscovery: json['multipeerDiscovery'] as bool? ?? false,
      wifiAwareDiscovery: json['wifiAwareDiscovery'] as bool? ?? false,
      hotspotFallback: json['hotspotFallback'] as bool? ?? false,
      nfcPairing: json['nfcPairing'] as bool? ?? false,
      syncInBackground: json['syncInBackground'] as bool? ?? true,
      syncNow: json['syncNow'] as bool? ?? true,
      scheduleEnabled: json['scheduleEnabled'] as bool? ?? false,
      scheduleUnit: _scheduleUnitFromJson(json['scheduleUnit']),
      scheduleEvery: _positive(json['scheduleEvery'] as int? ?? 1),
      scheduleAnchorDay: json['scheduleAnchorDay'] as int? ?? 0,
      scheduleTimes: _scheduleTimes(
        rawTimes?.whereType<int>().toList() ?? [legacyStart],
      ),
      scheduleWindowMinutes: _positive(
        json['scheduleWindowMinutes'] as int? ??
            _legacyWindowMinutes(legacyStart, legacyEnd),
      ),
      activityLogPath: json['activityLogPath'] as String?,
      localeCode: json['localeCode'] as String?,
    );
  }
}

SyncScheduleUnit _scheduleUnitFromJson(Object? value) {
  if (value is String) {
    for (final unit in SyncScheduleUnit.values) {
      if (unit.name == value) return unit;
    }
  }
  return SyncScheduleUnit.days;
}

int _legacyWindowMinutes(int start, int end) {
  final normalizedStart = start.clamp(0, 1439).toInt();
  final normalizedEnd = end.clamp(0, 1439).toInt();
  final minutes = normalizedEnd >= normalizedStart
      ? normalizedEnd - normalizedStart
      : 1440 - normalizedStart + normalizedEnd;
  return minutes == 0 ? 30 : minutes;
}

int _positive(int value) => value < 1 ? 1 : value;

List<int> _scheduleTimes(List<int> values) {
  final times = {
    for (final value in values) value.clamp(0, 1439).toInt(),
  }.toList()..sort();
  return times.isEmpty ? const [720] : times;
}
