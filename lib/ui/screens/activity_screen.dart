import 'package:declar_ui/declar_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3e_core/m3e_core.dart';

import '../../i18n/strings.g.dart';
import '../../state/events_provider.dart';
import '../../state/peers_provider.dart';
import '../../sync/sync_event.dart';
import '../widgets/activity_event_tile.dart';
import '../widgets/empty_state.dart';
import '../widgets/expressive.dart';
import '../widgets/live_transactions.dart';

const _activityDesktopWidth = 960.0;

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(syncEventsProvider);
    final peers = ref.watch(pairedPeersProvider).value ?? const [];
    final names = {for (final peer in peers) peer.deviceId: peer.name};

    return SafeArea(
      top: false,
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          const LiveTransactions(),
          Expanded(
            child: _ActivityBody(events: events, names: names),
          ),
        ],
      ),
    );
  }
}

class _ActivityBody extends ConsumerWidget {
  const _ActivityBody({required this.events, required this.names});

  final List<SyncEvent> events;
  final Map<String, String> names;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (events.isEmpty) {
      return EmptyState(
        icon: Icons.sync_rounded,
        title: context.t.activity.empty,
        message: context.t.activity.emptyHint,
      );
    }

    if (MediaQuery.sizeOf(context).width >= expressiveMediumBreakpoint) {
      final padding = expressiveScreenPadding(context).copyWith(top: 0);
      return ExpressiveReveal(
        child: Padding(
          padding: padding,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: _activityDesktopWidth,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ListView(
                  key: const ValueKey('activity-desktop-list'),
                  padding: EdgeInsets.zero,
                  children: [
                    M3ECardList(
                      itemCount: events.length,
                      itemBuilder: (context, index) => Row(
                        children: [
                          Expanded(
                            child: _ActivityEventRow(
                              event: events[index],
                              names: names,
                            ),
                          ),
                          ActivityEventMenu(
                            event: events[index],
                            onDelete: () => ref
                                .read(syncEventsProvider.notifier)
                                .removeAt(index),
                          ),
                        ],
                      ),
                      outerRadius: expressiveListOuterRadius,
                      innerRadius: expressiveListInnerRadius,
                      gap: expressiveListGap,
                      color: context.colors.surfaceContainerHigh,
                      padding: expressiveListPadding,
                      margin: expressiveListMargin,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return ExpressiveReveal(
      child: ListView.builder(
        key: const ValueKey('activity-list'),
        padding: expressiveListPaddingFor(context),
        itemCount: events.length,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.fromLTRB(12, 0, 12, expressiveListGap + 3),
          child: ActivityEventTile(
            event: events[index],
            onDelete: () =>
                ref.read(syncEventsProvider.notifier).removeAt(index),
            child: _ActivityEventRow(event: events[index], names: names),
          ),
        ),
      ),
    );
  }
}

class _ActivityEventRow extends StatelessWidget {
  const _ActivityEventRow({required this.event, required this.names});

  final SyncEvent event;
  final Map<String, String> names;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (icon, background, foreground) = _appearance(context, event.kind);
    final peer = event.peerId == null
        ? null
        : names[event.peerId] ?? event.peerId;
    final transport = event.transport == null
        ? null
        : _transportLabel(context, event.transport!);
    final details = [?event.path, ?peer];

    return Row(
      crossAxisAlignment: .start,
      children: [
        ExpressiveIconContainer(
          icon: icon,
          color: background,
          foregroundColor: foreground,
          size: 52,
          radius: 18,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Row(
                crossAxisAlignment: .start,
                children: [
                  Expanded(
                    child: Text(
                      _title(context, event.kind),
                    ).size(15).weight(.w800).color(colors.onSurface),
                  ),
                  const SizedBox(width: 10),
                  _TimePill(time: _time(event.at)),
                ],
              ),
              if (details.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(details.join(' · '))
                    .size(13)
                    .color(colors.onSurfaceVariant)
                    .maxLines(2)
                    .overflow(.ellipsis),
              ],
              if (transport != null) ...[
                const SizedBox(height: 10),
                ExpressiveStatusPill(
                  label: transport,
                  icon: _transportIcon(event.transport!),
                  color: colors.surfaceContainerHighest,
                  foregroundColor: colors.onSurfaceVariant,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TimePill extends StatelessWidget {
  const _TimePill({required this.time});

  final String time;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(time).size(11).weight(.w800).color(colors.onSurfaceVariant),
    );
  }
}

String _title(BuildContext context, SyncEventKind kind) => switch (kind) {
  SyncEventKind.connecting => context.t.activity.eventConnecting,
  SyncEventKind.connected => context.t.activity.eventConnected,
  SyncEventKind.disconnected => context.t.activity.eventDisconnected,
  SyncEventKind.received => context.t.activity.eventReceived,
  SyncEventKind.conflict => context.t.activity.eventConflict,
};

String _transportLabel(BuildContext context, String transport) =>
    switch (transport) {
      'tcp' => context.t.activity.transportTcp,
      'lan' => context.t.activity.transportLan,
      'wifi-direct' => context.t.activity.transportWifiDirect,
      'multipeer' => context.t.activity.transportMultipeer,
      'wifi-aware' => context.t.activity.transportWifiAware,
      'bluetooth' => context.t.activity.transportBluetooth,
      _ => transport,
    };

IconData _transportIcon(String transport) => switch (transport) {
  'tcp' => Icons.settings_ethernet_rounded,
  'lan' => Icons.router_rounded,
  'wifi-direct' => Icons.wifi_tethering_rounded,
  'multipeer' => Icons.devices_rounded,
  'wifi-aware' => Icons.cell_tower_rounded,
  'bluetooth' => Icons.bluetooth_rounded,
  _ => Icons.hub_rounded,
};

String _time(DateTime at) {
  final local = at.toLocal();
  return '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}

(IconData, Color, Color) _appearance(BuildContext context, SyncEventKind kind) {
  final colors = context.colors;
  return switch (kind) {
    SyncEventKind.connecting => (
      Icons.sync_rounded,
      colors.secondaryContainer,
      colors.onSecondaryContainer,
    ),
    SyncEventKind.received => (
      Icons.download_done_rounded,
      colors.primaryContainer,
      colors.onPrimaryContainer,
    ),
    SyncEventKind.conflict => (
      Icons.warning_amber_rounded,
      colors.errorContainer,
      colors.onErrorContainer,
    ),
    SyncEventKind.connected => (
      Icons.link_rounded,
      colors.tertiaryContainer,
      colors.onTertiaryContainer,
    ),
    SyncEventKind.disconnected => (
      Icons.link_off_rounded,
      colors.surfaceContainerHighest,
      colors.onSurfaceVariant,
    ),
  };
}
