import 'package:declar_ui/declar_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3e_core/m3e_core.dart';

import '../../../i18n/strings.g.dart';
import '../../../state/app_providers.dart';
import '../../widgets/expressive.dart';
import '../../widgets/ice_server_dialog.dart';
import '../../widgets/setting_tile.dart';
import 'settings_page_scaffold.dart';

class SignalingSettingsScreen extends ConsumerWidget {
  const SignalingSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider);
    final notifier = ref.read(configProvider.notifier);
    final colors = context.colors;
    final t = context.t.settings;

    return SettingsPageScaffold(
      title: t.signaling,
      children: [
        ExpressiveSection(
          title: t.signaling,
          trailing: M3EButton.icon(
            onPressed: () async {
              final server = await showIceServerDialog(context);
              if (server != null) notifier.addIceServer(server);
            },
            icon: const Icon(Icons.add_rounded),
            label: Text(t.addServer),
            style: .tonal,
            size: .sm,
          ),
          children: [
            if (config.iceServers.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  t.defaultStun,
                ).size(14).color(colors.onSurfaceVariant).align(.center),
              ),
            for (var i = 0; i < config.iceServers.length; i++)
              SettingTile(
                icon: config.iceServers[i].isTurn
                    ? Icons.dns_rounded
                    : Icons.lan_rounded,
                title: config.iceServers[i].url,
                subtitle: config.iceServers[i].isTurn ? 'TURN' : 'STUN',
                trailing: IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => notifier.removeIceServer(i),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
