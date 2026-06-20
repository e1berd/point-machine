import 'package:sembast/sembast.dart';

import '../core/models.dart';
import 'version_vector.dart';

class IndexEntry {
  const IndexEntry(this.meta, this.version);

  final FileMeta meta;
  final VersionVector version;
}

class FolderIndex {
  FolderIndex(this._db, String folderId)
      : _store = stringMapStoreFactory.store('index/$folderId');

  final Database _db;
  final StoreRef<String, Map<String, Object?>> _store;

  Future<void> put(IndexEntry entry) =>
      _store.record(entry.meta.path).put(_db, _encode(entry));

  Future<IndexEntry?> get(String path) async {
    final value = await _store.record(path).get(_db);
    return value == null ? null : _decode(path, value);
  }

  Future<List<IndexEntry>> all() async {
    final records = await _store.find(_db);
    return [for (final record in records) _decode(record.key, record.value)];
  }

  Future<void> delete(String path) => _store.record(path).delete(_db);

  Map<String, Object?> _encode(IndexEntry entry) => {
        'size': entry.meta.size,
        'modified': entry.meta.modified.toUtc().millisecondsSinceEpoch,
        'blocks': entry.meta.blockHashes,
        'deleted': entry.meta.deleted,
        'version': entry.version.toMap(),
      };

  IndexEntry _decode(String path, Map<String, Object?> value) => IndexEntry(
        FileMeta(
          path: path,
          size: value['size'] as int,
          modified: DateTime.fromMillisecondsSinceEpoch(
            value['modified'] as int,
            isUtc: true,
          ),
          blockHashes: (value['blocks'] as List).cast<String>(),
          deleted: value['deleted'] as bool? ?? false,
        ),
        VersionVector.fromMap((value['version'] as Map).cast<String, dynamic>()),
      );
}
