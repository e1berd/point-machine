import 'dart:typed_data';

import 'package:point_machine/sync/blocks.dart';
import 'package:test/test.dart';

void main() {
  test('splits into deterministic per-block hashes', () async {
    final data =
        Uint8List.fromList(List<int>.generate(blockSize * 2 + 5, (i) => i % 256));

    final first = await hashBlocks(data);
    final second = await hashBlocks(data);
    expect(first, equals(second));
    expect(first.length, equals(3));
    expect(blockCountFor(data.length), equals(3));
  });

  test('empty data yields no blocks', () async {
    expect(await hashBlocks(Uint8List(0)), isEmpty);
    expect(blockCountFor(0), equals(0));
  });
}
