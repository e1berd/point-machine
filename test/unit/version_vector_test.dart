import 'package:point_machine/sync/version_vector.dart';
import 'package:test/test.dart';

void main() {
  test('successive increments dominate earlier versions', () {
    final first = VersionVector.empty.increment('d1');
    final second = first.increment('d1');
    expect(second.dominates(first), isTrue);
    expect(first.dominates(second), isFalse);
  });

  test('divergent edits are concurrent and merge to dominate both', () {
    final base = VersionVector.empty.increment('d1');
    final left = base.increment('d1');
    final right = base.increment('d2');
    expect(left.concurrentWith(right), isTrue);

    final merged = left.merge(right);
    expect(merged.dominates(left), isTrue);
    expect(merged.dominates(right), isTrue);
  });
}
