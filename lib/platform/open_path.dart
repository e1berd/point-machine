import 'dart:io';

import 'package:flutter/services.dart';

const _channel = MethodChannel('tech.hammerhead.mesh_market/open_path');

Future<bool> openFolderInFileManager(String path) async {
  final directory = Directory(path);

  if (Platform.isAndroid || Platform.isIOS) {
    return _openMobileFolder(path);
  }

  if (!await directory.exists()) return false;

  if (Platform.isLinux) return _run('xdg-open', [path]);
  if (Platform.isMacOS) return _run('open', [path]);
  if (Platform.isWindows) return _run('explorer.exe', [path]);

  return false;
}

Future<bool> _openMobileFolder(String path) async {
  try {
    return await _channel.invokeMethod<bool>('openFolder', {'path': path}) ??
        false;
  } on MissingPluginException {
    return false;
  } on PlatformException {
    return false;
  }
}

Future<bool> _run(String executable, List<String> arguments) async {
  try {
    final result = await Process.run(executable, arguments);
    return result.exitCode == 0;
  } on Object {
    return false;
  }
}
