import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config.dart';
import 'app_providers.dart';

final _epoch = DateTime(1970);

bool syncWindowActive(AppConfig config, DateTime now) {
  if (config.syncNow) return true;
  if (!config.scheduleEnabled) return false;
  final today = DateTime(now.year, now.month, now.day);
  for (final dayOffset in [0, -1]) {
    final date = today.add(Duration(days: dayOffset));
    if (!_dateAllowed(config, date)) continue;
    for (final minutes in config.scheduleTimes) {
      final start = date.add(Duration(minutes: minutes));
      final end = start.add(Duration(minutes: config.scheduleWindowMinutes));
      if (!now.isBefore(start) && now.isBefore(end)) return true;
    }
  }
  return false;
}

int localEpochDay(DateTime date) {
  final localDate = DateTime(date.year, date.month, date.day);
  return localDate.difference(_epoch).inDays;
}

DateTime localDateFromEpochDay(int day) => _epoch.add(Duration(days: day));

bool _dateAllowed(AppConfig config, DateTime date) {
  final anchor = localDateFromEpochDay(config.scheduleAnchorDay);
  final every = config.scheduleEvery < 1 ? 1 : config.scheduleEvery;
  return switch (config.scheduleUnit) {
    SyncScheduleUnit.days => _dayIntervalAllowed(anchor, date, every),
    SyncScheduleUnit.months => _monthIntervalAllowed(anchor, date, every),
  };
}

bool _dayIntervalAllowed(DateTime anchor, DateTime date, int every) {
  final diff = date.difference(anchor).inDays;
  return diff >= 0 && diff % every == 0;
}

bool _monthIntervalAllowed(DateTime anchor, DateTime date, int every) {
  final months = (date.year - anchor.year) * 12 + date.month - anchor.month;
  if (months < 0 || months % every != 0) return false;
  return date.day == _effectiveMonthDay(anchor.day, date.year, date.month);
}

int _effectiveMonthDay(int anchorDay, int year, int month) {
  final lastDay = DateTime(year, month + 1, 0).day;
  return anchorDay > lastDay ? lastDay : anchorDay;
}

final syncActiveProvider = StreamProvider<bool>((ref) async* {
  final config = ref.watch(configProvider);
  yield syncWindowActive(config, DateTime.now());
  yield* Stream.periodic(
    const Duration(seconds: 20),
    (_) => syncWindowActive(config, DateTime.now()),
  );
});
