import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

Future<bool> ensureStorageAccess() async {
  if (!Platform.isAndroid) return true;
  if (await Permission.manageExternalStorage.isGranted) return true;
  final status = await Permission.manageExternalStorage.request();
  return status.isGranted;
}

String resolveAndroidDirectory(String picked) {
  if (!Platform.isAndroid || !picked.startsWith('content://')) return picked;
  const treeMarker = '/tree/';
  final treeIndex = picked.indexOf(treeMarker);
  if (treeIndex < 0) return picked;

  var docId = picked.substring(treeIndex + treeMarker.length);
  const docMarker = '/document/';
  final docIndex = docId.indexOf(docMarker);
  if (docIndex >= 0) docId = docId.substring(0, docIndex);
  docId = Uri.decodeComponent(docId);

  final colon = docId.indexOf(':');
  if (colon < 0) return picked;
  final volume = docId.substring(0, colon);
  final relative = docId.substring(colon + 1);
  final base = volume == 'primary' ? '/storage/emulated/0' : '/storage/$volume';
  return relative.isEmpty ? base : '$base/$relative';
}
