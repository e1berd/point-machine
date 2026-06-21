import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../core/folder_codec.dart';
import '../core/folder_share.dart';
import '../core/models.dart';
import '../core/paths.dart';
import '../transport/swarm.dart';
import 'sync_provider.dart';

final foldersProvider =
    AsyncNotifierProvider<FoldersNotifier, List<FolderConfig>>(
      FoldersNotifier.new,
    );

final folderFileCountProvider = FutureProvider.family<int, String>((
  ref,
  folderId,
) async {
  final controller = await ref.watch(syncControllerProvider.future);
  return controller.folderCount(folderId);
});

final folderExistsProvider =
    FutureProvider.family<bool, String>((ref, path) => Directory(path).exists());

class FoldersNotifier extends AsyncNotifier<List<FolderConfig>> {
  late File _file;

  @override
  Future<List<FolderConfig>> build() async {
    _file = File(p.join((await appDataDir()).path, 'folders.json'));
    if (!await _file.exists()) return const [];
    return foldersFromJson(await _file.readAsString());
  }

  Future<bool> add(String path) async {
    final normalizedPath = p.normalize(p.absolute(path));
    final existing = [...?state.value];
    if (existing.any(
      (folder) => p.normalize(p.absolute(folder.localPath)) == normalizedPath,
    )) {
      return false;
    }

    final folder = FolderConfig(
      id: DateTime.now().microsecondsSinceEpoch.toRadixString(36),
      label: p.basename(normalizedPath),
      localPath: normalizedPath,
      swarmSecret: newSwarmSecret(),
    );
    await _persist([...existing, folder]);
    await scan(folder);
    return true;
  }

  Future<void> remove(String id) async =>
      _persist([...?state.value]..removeWhere((folder) => folder.id == id));

  FolderShare shareOf(FolderConfig folder) => FolderShare(
    folderId: folder.id,
    label: folder.label,
    swarmSecret: folder.swarmSecret,
  );

  Future<void> addPeer(
    String folderId,
    String peerId, {
    bool canSend = true,
    bool canReceive = true,
  }) async => _persist([
    for (final folder in [...?state.value])
      folder.id == folderId && !folder.peerIds.contains(peerId)
          ? FolderConfig(
              id: folder.id,
              label: folder.label,
              localPath: folder.localPath,
              swarmSecret: folder.swarmSecret,
              peers: [
                ...folder.peers,
                FolderPeer(
                  deviceId: peerId,
                  canSend: canSend,
                  canReceive: canReceive,
                ),
              ],
            )
          : folder,
  ]);

  Future<void> removePeer(String folderId, String peerId) async => _persist([
    for (final folder in [...?state.value])
      folder.id == folderId
          ? FolderConfig(
              id: folder.id,
              label: folder.label,
              localPath: folder.localPath,
              swarmSecret: folder.swarmSecret,
              peers: [
                for (final p in folder.peers)
                  if (p.deviceId != peerId) p,
              ],
            )
          : folder,
  ]);

  Future<void> updatePeer(
    String folderId,
    String peerId, {
    bool? canSend,
    bool? canReceive,
  }) async => _persist([
    for (final folder in [...?state.value])
      folder.id == folderId
          ? FolderConfig(
              id: folder.id,
              label: folder.label,
              localPath: folder.localPath,
              swarmSecret: folder.swarmSecret,
              peers: [
                for (final p in folder.peers)
                  if (p.deviceId == peerId)
                    p.copyWith(canSend: canSend, canReceive: canReceive)
                  else
                    p,
              ],
            )
          : folder,
  ]);

  Future<void> acceptShare(
    FolderShare share,
    String localPath,
    String peerId,
  ) async {
    final existing = [...?state.value];
    if (existing.any((folder) => folder.id == share.folderId)) {
      await addPeer(share.folderId, peerId);
      return;
    }
    final folder = FolderConfig(
      id: share.folderId,
      label: share.label,
      localPath: localPath,
      swarmSecret: share.swarmSecret,
      peers: [FolderPeer(deviceId: peerId)],
    );
    await _persist([...existing, folder]);
    await scan(folder);
  }

  Future<int> scan(FolderConfig folder) async {
    final controller = await ref.read(syncControllerProvider.future);
    await controller.rescan(folder.id);
    ref.invalidate(folderFileCountProvider(folder.id));
    return controller.folderCount(folder.id);
  }

  Future<void> _persist(List<FolderConfig> folders) async {
    await _file.writeAsString(foldersToJson(folders));
    state = AsyncData(folders);
  }
}
