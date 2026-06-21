import 'dart:convert';

import 'models.dart';

Map<String, Object?> folderToMap(FolderConfig folder) => {
  'id': folder.id,
  'label': folder.label,
  'path': folder.localPath,
  'swarm': base64Encode(folder.swarmSecret),
  'peers': [for (final p in folder.peers) p.toJson()],
};

FolderConfig folderFromMap(Map<String, Object?> map) {
  final rawPeers = map['peers'] as List?;
  final List<FolderPeer> peers;
  if (rawPeers != null && rawPeers.isNotEmpty) {
    final first = rawPeers.first;
    peers = first is Map
        ? [
            for (final item in rawPeers)
              FolderPeer.fromJson((item as Map).cast<String, Object?>()),
          ]
        : [for (final item in rawPeers) FolderPeer(deviceId: item as String)];
  } else {
    peers = const [];
  }
  return FolderConfig(
    id: map['id'] as String,
    label: map['label'] as String,
    localPath: map['path'] as String,
    swarmSecret: base64Decode(map['swarm'] as String),
    peers: peers,
  );
}

List<FolderConfig> foldersFromJson(String json) => [
  for (final item in jsonDecode(json) as List)
    folderFromMap((item as Map).cast<String, Object?>()),
];

String foldersToJson(List<FolderConfig> folders) =>
    jsonEncode([for (final f in folders) folderToMap(f)]);
