import 'package:declar_ui/declar_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config.dart';
import '../../i18n/strings.g.dart';
import '../../state/app_providers.dart';
import '../../state/events_provider.dart';
import '../../state/sync_schedule_provider.dart';
import '../../sync/sync_event.dart';
import 'expressive.dart';

String _formatMinutes(int minutes) =>
    '${(minutes ~/ 60).toString().padLeft(2, '0')}:'
    '${(minutes % 60).toString().padLeft(2, '0')}';

class ScheduleControls extends ConsumerWidget {
  const ScheduleControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final config = ref.watch(configProvider);
    final active = ref.watch(syncActiveProvider).value ?? false;
    final activeTransports = _activeTransports(ref.watch(syncEventsProvider));
    final notifier = ref.read(configProvider.notifier);

    return Material(
      color: colors.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.t.schedule.title,
                  ).size(18).weight(.w800),
                ),
                _statusPill(context, active, activeTransports),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.t.schedule.syncNow),
              subtitle: Text(context.t.schedule.syncNowHint),
              value: config.syncNow,
              onChanged: notifier.setSyncNow,
            ),
            const Divider(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.t.schedule.scheduleTitle),
              subtitle: Text(context.t.schedule.scheduleHint),
              value: config.scheduleEnabled,
              onChanged: notifier.setScheduleEnabled,
            ),
            if (config.scheduleEnabled)
              Column(
                crossAxisAlignment: .stretch,
                children: [
                  _scheduleSummary(context, config),
                  const SizedBox(height: 14),
                  _repeatControls(context, notifier, config),
                  const SizedBox(height: 14),
                  _windowControls(context, notifier, config),
                  const SizedBox(height: 14),
                  _timeControls(context, ref, config),
                ],
              ).padding(top: 8, bottom: 8),
          ],
        ),
      ),
    );
  }

  Widget _statusPill(
    BuildContext context,
    bool active,
    List<String> activeTransports,
  ) {
    final colors = context.colors;
    final background = active
        ? colors.primaryContainer
        : colors.surfaceContainerHighest;
    final foreground = active
        ? colors.onPrimaryContainer
        : colors.onSurfaceVariant;
    final label = activeTransports.isEmpty
        ? (active ? context.t.schedule.active : context.t.schedule.paused)
        : activeTransports
              .map((transport) => _transportLabel(context, transport))
              .join(', ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: .min,
        children: [
          Icon(
            active ? Icons.sync_rounded : Icons.pause_rounded,
            size: 16,
            color: foreground,
          ),
          const SizedBox(width: 6),
          Text(label).size(12).weight(.w700).color(foreground),
        ],
      ),
    );
  }

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

  Widget _scheduleSummary(BuildContext context, AppConfig config) {
    final colors = context.colors;
    final unit = config.scheduleUnit == SyncScheduleUnit.days
        ? context.t.schedule.repeatDays.toLowerCase()
        : context.t.schedule.repeatMonths.toLowerCase();
    final runs = config.scheduleTimes.length;
    return ExpressiveSpringContainer(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          ExpressiveIconContainer(
            icon: Icons.event_repeat_rounded,
            color: colors.primary,
            foregroundColor: colors.onPrimary,
            size: 56,
            radius: 20,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  '${context.t.schedule.every} ${config.scheduleEvery} $unit',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ).size(22).weight(.w900).color(colors.onPrimaryContainer),
                const SizedBox(height: 3),
                Text(
                      '$runs x ${context.t.schedule.minutes(n: config.scheduleWindowMinutes)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                    .size(13)
                    .weight(.w700)
                    .color(colors.onPrimaryContainer.withValues(alpha: .72)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _repeatControls(
    BuildContext context,
    ConfigNotifier notifier,
    AppConfig config,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;
        final repeat = _ScheduleControlGroup(
          label: context.t.schedule.repeat,
          icon: Icons.repeat_rounded,
          child: _ExpressiveSegmented<SyncScheduleUnit>(
            value: config.scheduleUnit,
            values: [
              _SegmentOption(
                value: SyncScheduleUnit.days,
                icon: Icons.calendar_view_week_rounded,
                label: context.t.schedule.repeatDays,
              ),
              _SegmentOption(
                value: SyncScheduleUnit.months,
                icon: Icons.calendar_month_rounded,
                label: context.t.schedule.repeatMonths,
              ),
            ],
            onChanged: (unit) =>
                notifier.setScheduleCadence(unit, config.scheduleEvery),
          ),
        );
        final every = _ScheduleControlGroup(
          label: context.t.schedule.every,
          icon: Icons.av_timer_rounded,
          child: _ExpressiveStepper(
            value: config.scheduleEvery,
            onMinus: config.scheduleEvery <= 1
                ? null
                : () => notifier.setScheduleCadence(
                    config.scheduleUnit,
                    config.scheduleEvery - 1,
                  ),
            onPlus: () => notifier.setScheduleCadence(
              config.scheduleUnit,
              config.scheduleEvery + 1,
            ),
          ),
        );

        if (compact) {
          return Column(
            crossAxisAlignment: .stretch,
            children: [repeat, const SizedBox(height: 10), every],
          );
        }

        return Row(
          crossAxisAlignment: .start,
          children: [
            Expanded(child: repeat),
            const SizedBox(width: 10),
            SizedBox(width: 220, child: every),
          ],
        );
      },
    );
  }

  Widget _windowControls(
    BuildContext context,
    ConfigNotifier notifier,
    AppConfig config,
  ) {
    final options = [15, 30, 60, 120];
    return _ScheduleControlGroup(
      label: context.t.schedule.window,
      icon: Icons.timelapse_rounded,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 560;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: options.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: compact ? 2 : 4,
              mainAxisExtent: 74,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final minutes = options[index];
              return _ExpressiveChoiceTile(
                icon: Icons.hourglass_bottom_rounded,
                label: context.t.schedule.minutes(n: minutes),
                selected: config.scheduleWindowMinutes == minutes,
                onTap: () => notifier.setScheduleWindow(minutes),
              );
            },
          );
        },
      ),
    );
  }

  Widget _timeControls(BuildContext context, WidgetRef ref, AppConfig config) {
    return _ScheduleControlGroup(
      label: context.t.schedule.timesTitle,
      icon: Icons.schedule_rounded,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (var i = 0; i < config.scheduleTimes.length; i++)
            _ScheduleTimePill(
              minutes: config.scheduleTimes[i],
              canDelete: config.scheduleTimes.length > 1,
              onTap: () async {
                final minutes = config.scheduleTimes[i];
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: minutes ~/ 60,
                    minute: minutes % 60,
                  ),
                );
                if (picked == null) return;
                ref
                    .read(configProvider.notifier)
                    .updateScheduleTime(i, picked.hour * 60 + picked.minute);
              },
              onDelete: () =>
                  ref.read(configProvider.notifier).removeScheduleTime(i),
            ),
          _AddTimePill(
            label: context.t.schedule.addTime,
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: const TimeOfDay(hour: 12, minute: 0),
              );
              if (picked == null) return;
              ref
                  .read(configProvider.notifier)
                  .addScheduleTime(picked.hour * 60 + picked.minute);
            },
          ),
        ],
      ),
    );
  }
}

class _ScheduleControlGroup extends StatelessWidget {
  const _ScheduleControlGroup({
    required this.label,
    required this.icon,
    required this.child,
  });

  final String label;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
          child: Row(
            children: [
              Icon(icon, size: 17, color: colors.primary),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ).size(12).weight(.w900).color(colors.primary),
              ),
            ],
          ),
        ),
        child,
      ],
    );
  }
}

class _SegmentOption<T> {
  const _SegmentOption({
    required this.value,
    required this.icon,
    required this.label,
  });

  final T value;
  final IconData icon;
  final String label;
}

class _ExpressiveSegmented<T> extends StatelessWidget {
  const _ExpressiveSegmented({
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final T value;
  final List<_SegmentOption<T>> values;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          for (final option in values)
            Expanded(
              child: _ExpressiveSegment(
                icon: option.icon,
                label: option.label,
                selected: option.value == value,
                onTap: () => onChanged(option.value),
              ),
            ),
        ],
      ),
    );
  }
}

class _ExpressiveSegment extends StatefulWidget {
  const _ExpressiveSegment({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_ExpressiveSegment> createState() => _ExpressiveSegmentState();
}

class _ExpressiveSegmentState extends State<_ExpressiveSegment> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final selected = widget.selected;
    final background = selected
        ? colors.secondaryContainer
        : Colors.transparent;
    final foreground = selected
        ? colors.onSecondaryContainer
        : colors.onSurfaceVariant;
    return AnimatedScale(
      scale: _pressed ? .97 : 1,
      duration: expressiveFastDuration,
      curve: expressiveCurve,
      child: AnimatedContainer(
        duration: expressiveFastDuration,
        curve: expressiveCurve,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(selected ? 24 : 18),
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: (_) => setState(() => _pressed = true),
            onTapCancel: () => setState(() => _pressed = false),
            onTapUp: (_) => setState(() => _pressed = false),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.icon, size: 19, color: foreground),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      widget.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ).size(14).weight(.w900).color(foreground),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpressiveStepper extends StatelessWidget {
  const _ExpressiveStepper({
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final int value;
  final VoidCallback? onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _RoundControlButton(icon: Icons.remove_rounded, onTap: onMinus),
          Expanded(
            child: Center(
              child: AnimatedSwitcher(
                duration: expressiveFastDuration,
                switchInCurve: expressiveCurve,
                switchOutCurve: expressiveExitCurve,
                child: Text(
                  '$value',
                  key: ValueKey(value),
                ).size(26).weight(.w900).color(colors.onSurface),
              ),
            ),
          ),
          _RoundControlButton(icon: Icons.add_rounded, onTap: onPlus),
        ],
      ),
    );
  }
}

class _RoundControlButton extends StatefulWidget {
  const _RoundControlButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  State<_RoundControlButton> createState() => _RoundControlButtonState();
}

class _RoundControlButtonState extends State<_RoundControlButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = widget.onTap != null;
    return AnimatedScale(
      scale: _pressed ? .92 : 1,
      duration: expressiveFastDuration,
      curve: expressiveCurve,
      child: Material(
        color: enabled
            ? colors.secondaryContainer
            : colors.surfaceContainerHigh,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
          onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
          onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
          customBorder: const CircleBorder(),
          child: SizedBox.square(
            dimension: 50,
            child: Icon(
              widget.icon,
              color: enabled
                  ? colors.onSecondaryContainer
                  : colors.onSurfaceVariant.withValues(alpha: .38),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpressiveChoiceTile extends StatefulWidget {
  const _ExpressiveChoiceTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_ExpressiveChoiceTile> createState() => _ExpressiveChoiceTileState();
}

class _ExpressiveChoiceTileState extends State<_ExpressiveChoiceTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final selected = widget.selected;
    return AnimatedScale(
      scale: _pressed ? .96 : 1,
      duration: expressiveFastDuration,
      curve: expressiveCurve,
      child: AnimatedContainer(
        duration: expressiveFastDuration,
        curve: expressiveCurve,
        decoration: BoxDecoration(
          color: selected ? colors.tertiaryContainer : colors.surfaceContainer,
          borderRadius: BorderRadius.circular(selected ? 26 : 18),
          border: Border.all(
            color: selected
                ? colors.tertiary.withValues(alpha: .54)
                : colors.outlineVariant.withValues(alpha: .34),
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: (_) => setState(() => _pressed = true),
            onTapCancel: () => setState(() => _pressed = false),
            onTapUp: (_) => setState(() => _pressed = false),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    selected ? Icons.check_circle_rounded : widget.icon,
                    size: 20,
                    color: selected
                        ? colors.onTertiaryContainer
                        : colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child:
                        Text(
                              widget.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                            .size(14)
                            .weight(.w900)
                            .color(
                              selected
                                  ? colors.onTertiaryContainer
                                  : colors.onSurface,
                            ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScheduleTimePill extends StatefulWidget {
  const _ScheduleTimePill({
    required this.minutes,
    required this.canDelete,
    required this.onTap,
    required this.onDelete,
  });

  final int minutes;
  final bool canDelete;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  State<_ScheduleTimePill> createState() => _ScheduleTimePillState();
}

class _ScheduleTimePillState extends State<_ScheduleTimePill> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedScale(
      scale: _pressed ? .97 : 1,
      duration: expressiveFastDuration,
      curve: expressiveCurve,
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(29),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: .3),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          mainAxisSize: .min,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                onTapDown: (_) => setState(() => _pressed = true),
                onTapCancel: () => setState(() => _pressed = false),
                onTapUp: (_) => setState(() => _pressed = false),
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 16, end: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 20,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 9),
                      Text(
                        _formatMinutes(widget.minutes),
                      ).size(19).weight(.w900).color(colors.onSurface),
                    ],
                  ),
                ),
              ),
            ),
            if (widget.canDelete)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 5),
                child: IconButton(
                  tooltip: MaterialLocalizations.of(
                    context,
                  ).deleteButtonTooltip,
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.close_rounded, size: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AddTimePill extends StatefulWidget {
  const _AddTimePill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_AddTimePill> createState() => _AddTimePillState();
}

class _AddTimePillState extends State<_AddTimePill> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedScale(
      scale: _pressed ? .97 : 1,
      duration: expressiveFastDuration,
      curve: expressiveCurve,
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: colors.secondaryContainer.withValues(alpha: .62),
          borderRadius: BorderRadius.circular(29),
          border: Border.all(color: colors.secondary.withValues(alpha: .38)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: (_) => setState(() => _pressed = true),
            onTapCancel: () => setState(() => _pressed = false),
            onTapUp: (_) => setState(() => _pressed = false),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: .min,
                children: [
                  Icon(
                    Icons.add_rounded,
                    size: 20,
                    color: colors.onSecondaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ).size(14).weight(.w900).color(colors.onSecondaryContainer),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

List<String> _activeTransports(List<SyncEvent> events) {
  final active = <String, String>{};
  for (final event in events.reversed) {
    if (event.peerId == null ||
        event.folderId == null ||
        event.transport == null) {
      continue;
    }
    final key = '${event.peerId}/${event.folderId}';
    switch (event.kind) {
      case SyncEventKind.connecting:
      case SyncEventKind.connected:
        active[key] = event.transport!;
      case SyncEventKind.disconnected:
        active.remove(key);
      case SyncEventKind.received || SyncEventKind.conflict:
        break;
    }
  }
  return active.values.toSet().toList()..sort();
}
