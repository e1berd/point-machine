import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../core/paths.dart';
import '../platform/open_path.dart';
import '../sync/sync_event.dart';
import 'app_providers.dart';

final activityLogPathProvider = FutureProvider<String>((ref) async {
  final configured = ref.watch(
    configProvider.select((config) => config.activityLogPath),
  );
  if (configured != null && configured.trim().isNotEmpty) return configured;
  final dir = await appDataDir();
  return p.join(dir.path, 'activity.log');
});

final activityLogControllerProvider = Provider<ActivityLogController>(
  ActivityLogController.new,
);

class ActivityLogController {
  const ActivityLogController(this.ref);

  final Ref ref;

  Future<String> path() => ref.read(activityLogPathProvider.future);

  Future<void> append(SyncEvent event) async {
    final file = File(await path());
    await file.parent.create(recursive: true);
    await file.writeAsString('${_line(event)}\n', mode: FileMode.append);
  }

  Future<void> clear() async {
    final file = File(await path());
    await file.parent.create(recursive: true);
    await file.writeAsString('', flush: true);
  }

  Future<String?> choosePath({String? dialogTitle}) async {
    final current = await path();
    final file = File(current);
    final bytes = await file.exists() ? await file.readAsBytes() : Uint8List(0);
    final selected = await FilePicker.platform.saveFile(
      dialogTitle: dialogTitle,
      fileName: p.basename(current),
      initialDirectory: p.dirname(current),
      allowedExtensions: const ['log', 'txt'],
      type: FileType.custom,
      bytes: bytes,
    );
    if (selected == null || selected.trim().isEmpty) return null;
    ref.read(configProvider.notifier).setActivityLogPath(selected);
    ref.invalidate(activityLogPathProvider);
    return selected;
  }

  Future<bool> openLocation() async {
    final logPath = await path();
    final file = File(logPath);
    await file.parent.create(recursive: true);
    if (Platform.isAndroid || Platform.isIOS) {
      final bytes = await file.exists()
          ? await file.readAsBytes()
          : Uint8List(0);
      final exported = await FilePicker.platform.saveFile(
        fileName: p.basename(logPath),
        bytes: bytes,
      );
      return exported != null;
    }
    return openFolderInFileManager(file.parent.path);
  }

  String _line(SyncEvent event) {
    final fields = {
      'at': event.at.toUtc().toIso8601String(),
      'kind': event.kind.name,
      if (event.peerId != null) 'peer': event.peerId!,
      if (event.folderId != null) 'folder': event.folderId!,
      if (event.transport != null) 'transport': event.transport!,
      if (event.path != null) 'path': event.path!,
    };
    return fields.entries
        .map((entry) => '${entry.key}=${entry.value}')
        .join(' ');
  }
}
