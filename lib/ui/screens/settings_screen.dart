import 'package:declar_ui/declar_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3e_core/m3e_core.dart';

import '../../state/app_providers.dart';
import '../widgets/ice_server_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider);
    final notifier = ref.read(configProvider.notifier);

    return Column(
      children: [
        _header(context, 'Appearance'),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(
                value: .system,
                label: Text('System'),
                icon: Icon(Icons.brightness_auto_rounded)),
            ButtonSegment(
                value: .light,
                label: Text('Light'),
                icon: Icon(Icons.light_mode_rounded)),
            ButtonSegment(
                value: .dark,
                label: Text('Dark'),
                icon: Icon(Icons.dark_mode_rounded)),
          ],
          selected: {config.themeMode},
          onSelectionChanged: (selection) =>
              notifier.setThemeMode(selection.first),
        ),
        _header(context, 'Discovery'),
        SwitchListTile(
          title: const Text('Local network (mDNS)'),
          subtitle: const Text('Find peers on the same network, no servers'),
          value: config.lanDiscovery,
          onChanged: notifier.toggleLanDiscovery,
        ),
        SwitchListTile(
          title: const Text('Internet (DHT)'),
          subtitle: const Text('Find peers across networks via the public DHT'),
          value: config.dhtDiscovery,
          onChanged: notifier.toggleDhtDiscovery,
        ),
        SwitchListTile(
          title: const Text('Sync in background'),
          subtitle: const Text('Keep syncing while the app is not focused'),
          value: config.syncInBackground,
          onChanged: notifier.toggleBackground,
        ),
        _header(context, 'Signaling (STUN / TURN)'),
        for (var i = 0; i < config.iceServers.length; i++)
          ListTile(
            leading: Icon(config.iceServers[i].isTurn
                ? Icons.dns_rounded
                : Icons.lan_rounded),
            title: Text(config.iceServers[i].url),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () => notifier.removeIceServer(i),
            ),
          ),
        M3EButton.icon(
          onPressed: () async {
            final server = await showIceServerDialog(context);
            if (server != null) notifier.addIceServer(server);
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add server'),
          style: .tonal,
        ).padding(top: 8),
      ],
    ).spacing(8).crossAlign(.stretch).padding(all: 16).scrollable();
  }
}

Widget _header(BuildContext context, String title) => Text(title)
    .size(13)
    .weight(.w700)
    .color(context.colors.primary)
    .padding(top: 12, left: 4);
