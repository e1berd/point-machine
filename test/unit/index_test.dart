import 'package:point_machine/core/models.dart';
import 'package:point_machine/sync/index.dart';
import 'package:point_machine/sync/version_vector.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:test/test.dart';

void main() {
  test('round-trips entries and deletes them', () async {
    final db = await databaseFactoryMemory.openDatabase('index_test.db');
    final index = FolderIndex(db, 'folder1');
    final entry = IndexEntry(
      FileMeta(
        path: 'docs/notes.txt',
        size: 42,
        modified: DateTime.utc(2026, 6, 20),
        blockHashes: const ['aa', 'bb'],
      ),
      VersionVector.empty.increment('d1'),
    );

    await index.put(entry);
    final read = await index.get('docs/notes.txt');
    expect(read!.meta.size, equals(42));
    expect(read.meta.blockHashes, equals(['aa', 'bb']));
    expect(read.version.counters['d1'], equals(1));
    expect((await index.all()).length, equals(1));

    await index.delete('docs/notes.txt');
    expect(await index.get('docs/notes.txt'), isNull);
  });
}
