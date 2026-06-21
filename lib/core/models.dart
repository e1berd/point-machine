import 'dart:typed_data';

class Device {
  const Device({
    required this.id,
    required this.name,
    this.online = false,
    this.lastSeen,
  });

  final String id;
  final String name;
  final bool online;
  final DateTime? lastSeen;
}

class FolderPeer {
  const FolderPeer({
    required this.deviceId,
    this.canSend = true,
    this.canReceive = true,
  });

  final String deviceId;
  final bool canSend;
  final bool canReceive;

  FolderPeer copyWith({bool? canSend, bool? canReceive}) => FolderPeer(
    deviceId: deviceId,
    canSend: canSend ?? this.canSend,
    canReceive: canReceive ?? this.canReceive,
  );

  Map<String, Object?> toJson() => {
    'id': deviceId,
    'send': canSend,
    'receive': canReceive,
  };

  factory FolderPeer.fromJson(Map<String, Object?> json) => FolderPeer(
    deviceId: json['id'] as String,
    canSend: json['send'] as bool? ?? true,
    canReceive: json['receive'] as bool? ?? true,
  );
}

class FolderConfig {
  const FolderConfig({
    required this.id,
    required this.label,
    required this.localPath,
    required this.swarmSecret,
    this.peers = const [],
  });

  final String id;
  final String label;
  final String localPath;
  final List<int> swarmSecret;
  final List<FolderPeer> peers;

  List<String> get peerIds => [for (final p in peers) p.deviceId];

  bool peerExists(String deviceId) => peers.any((p) => p.deviceId == deviceId);

  FolderPeer? peer(String deviceId) {
    for (final p in peers) {
      if (p.deviceId == deviceId) return p;
    }
    return null;
  }
}

class FileMeta {
  const FileMeta({
    required this.path,
    required this.size,
    required this.modified,
    required this.blockHashes,
    this.deleted = false,
  });

  final String path;
  final int size;
  final DateTime modified;
  final List<String> blockHashes;
  final bool deleted;
}

class FileBlock {
  const FileBlock({required this.index, required this.hash, required this.bytes});

  final int index;
  final String hash;
  final Uint8List bytes;
}
