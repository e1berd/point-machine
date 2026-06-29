import 'package:declar_ui/declar_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../i18n/strings.g.dart';
import '../widgets/expressive.dart';
import 'settings/appearance_settings_screen.dart';
import 'settings/discovery_settings_screen.dart';
import 'settings/logs_settings_screen.dart';
import 'settings/signaling_settings_screen.dart';
import 'settings/sync_settings_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t.settings;
    final entries = [
      _SettingsEntry(
        icon: Icons.palette_rounded,
        title: t.appearance,
        subtitle: t.appearanceSubtitle,
        builder: () => const AppearanceSettingsScreen(),
      ),
      _SettingsEntry(
        icon: Icons.sync_rounded,
        title: t.syncTitle,
        subtitle: t.syncSubtitle,
        builder: () => const SyncSettingsScreen(),
      ),
      _SettingsEntry(
        icon: Icons.travel_explore_rounded,
        title: t.discovery,
        subtitle: t.discoverySubtitle,
        builder: () => const DiscoverySettingsScreen(),
      ),
      _SettingsEntry(
        icon: Icons.receipt_long_rounded,
        title: t.logsTitle,
        subtitle: t.logsSubtitle,
        builder: () => const LogsSettingsScreen(),
      ),
      _SettingsEntry(
        icon: Icons.cell_tower_rounded,
        title: t.signaling,
        subtitle: t.signalingSubtitle,
        builder: () => const SignalingSettingsScreen(),
      ),
    ];

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        clipBehavior: Clip.hardEdge,
        child: ExpressiveResponsiveCenter(
          maxWidth: 760,
          child: Column(
            crossAxisAlignment: .stretch,
            spacing: 12,
            children: [
              for (var i = 0; i < entries.length; i++)
                ExpressiveReveal(
                  delay: Duration(milliseconds: 40 * i),
                  child: _SettingsNavTile(entry: entries[i]),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsEntry {
  const _SettingsEntry({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.builder,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget Function() builder;
}

class _SettingsNavTile extends StatefulWidget {
  const _SettingsNavTile({required this.entry});

  final _SettingsEntry entry;

  @override
  State<_SettingsNavTile> createState() => _SettingsNavTileState();
}

class _SettingsNavTileState extends State<_SettingsNavTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final entry = widget.entry;
    return AnimatedScale(
      scale: _pressed ? .97 : 1,
      duration: expressiveFastDuration,
      curve: expressiveCurve,
      child: Material(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(28),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push(entry.builder()),
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 18, 14),
            child: Row(
              children: [
                ExpressiveIconContainer(
                  icon: entry.icon,
                  color: colors.secondaryContainer,
                  foregroundColor: colors.onSecondaryContainer,
                  size: 52,
                  radius: 18,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        entry.title,
                      ).size(17).weight(.w800).color(colors.onSurface),
                      const SizedBox(height: 2),
                      Text(entry.subtitle)
                          .size(13)
                          .color(colors.onSurfaceVariant)
                          .maxLines(2)
                          .overflow(.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
