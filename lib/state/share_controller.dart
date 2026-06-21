import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models.dart';
import '../core/pairing.dart';
import 'app_providers.dart';
import 'folders_provider.dart';
import 'sync_provider.dart';

final shareControllerProvider = Provider<ShareController>(ShareController.new);

class ShareController {
  ShareController(this.ref);

  final Ref ref;

  Future<bool> shareWith(FolderConfig folder, PairingPayload peer) async {
    final share = ref.read(foldersProvider.notifier).shareOf(folder);
    await ref.read(foldersProvider.notifier).addPeer(folder.id, peer.deviceId);
    ref.read(configProvider.notifier).setSyncNow(true);
    final service = await ref.read(syncControllerProvider.future);
    return service.shareFolderWith(share, peer);
  }
}
