import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../sync/sync_event.dart';
import 'activity_log_provider.dart';

final syncEventsProvider =
    NotifierProvider<SyncEventsNotifier, List<SyncEvent>>(
      SyncEventsNotifier.new,
    );

class SyncEventsNotifier extends Notifier<List<SyncEvent>> {
  static const _limit = 100;

  @override
  List<SyncEvent> build() => const [];

  void add(SyncEvent event) {
    unawaited(ref.read(activityLogControllerProvider).append(event));
    final next = [event, ...state];
    state = next.length > _limit ? next.sublist(0, _limit) : next;
  }

  void removeAt(int index) {
    if (index < 0 || index >= state.length) return;
    state = [...state]..removeAt(index);
  }
}
