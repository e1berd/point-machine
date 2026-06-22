import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<Directory> appDataDir() async {
  final base = await getApplicationSupportDirectory();
  final dir = Directory(p.join(base.path, 'mesh-market'));
  await dir.create(recursive: true);
  return dir;
}
