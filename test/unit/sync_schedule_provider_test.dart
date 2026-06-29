import 'package:mesh_market/core/config.dart';
import 'package:mesh_market/state/sync_schedule_provider.dart';
import 'package:test/test.dart';

void main() {
  test('is active during any configured daily start window', () {
    final config = AppConfig(
      syncNow: false,
      scheduleEnabled: true,
      scheduleAnchorDay: localEpochDay(DateTime(2026, 6, 29)),
      scheduleTimes: const [8 * 60, 20 * 60],
      scheduleWindowMinutes: 30,
    );

    expect(syncWindowActive(config, DateTime(2026, 6, 29, 8, 10)), isTrue);
    expect(syncWindowActive(config, DateTime(2026, 6, 29, 20, 20)), isTrue);
    expect(syncWindowActive(config, DateTime(2026, 6, 29, 9)), isFalse);
  });

  test('supports every N days anchored from the configured day', () {
    final config = AppConfig(
      syncNow: false,
      scheduleEnabled: true,
      scheduleEvery: 2,
      scheduleAnchorDay: localEpochDay(DateTime(2026, 6, 29)),
      scheduleTimes: const [12 * 60],
      scheduleWindowMinutes: 60,
    );

    expect(syncWindowActive(config, DateTime(2026, 6, 29, 12, 30)), isTrue);
    expect(syncWindowActive(config, DateTime(2026, 6, 30, 12, 30)), isFalse);
    expect(syncWindowActive(config, DateTime(2026, 7, 1, 12, 30)), isTrue);
  });

  test('supports monthly schedules and clamps to the last month day', () {
    final config = AppConfig(
      syncNow: false,
      scheduleEnabled: true,
      scheduleUnit: SyncScheduleUnit.months,
      scheduleAnchorDay: localEpochDay(DateTime(2026, 1, 31)),
      scheduleTimes: const [12 * 60],
      scheduleWindowMinutes: 60,
    );

    expect(syncWindowActive(config, DateTime(2026, 2, 28, 12, 30)), isTrue);
    expect(syncWindowActive(config, DateTime(2026, 3, 30, 12, 30)), isFalse);
    expect(syncWindowActive(config, DateTime(2026, 3, 31, 12, 30)), isTrue);
  });

  test('keeps an overnight window active after midnight', () {
    final config = AppConfig(
      syncNow: false,
      scheduleEnabled: true,
      scheduleEvery: 2,
      scheduleAnchorDay: localEpochDay(DateTime(2026, 6, 29)),
      scheduleTimes: const [23 * 60 + 30],
      scheduleWindowMinutes: 90,
    );

    expect(syncWindowActive(config, DateTime(2026, 6, 29, 23, 45)), isTrue);
    expect(syncWindowActive(config, DateTime(2026, 6, 30, 0, 30)), isTrue);
    expect(syncWindowActive(config, DateTime(2026, 6, 30, 23, 45)), isFalse);
  });
}
