import 'dart:io';

import 'package:declar_ui/declar_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../i18n/strings.g.dart';
import '../../../state/app_providers.dart';
import '../../../transport/hotspot.dart';
import '../../widgets/expressive.dart';
import '../../widgets/setting_tile.dart';
import 'settings_page_scaffold.dart';

class DiscoverySettingsScreen extends ConsumerWidget {
  const DiscoverySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider);
    final notifier = ref.read(configProvider.notifier);
    final t = context.t.settings;

    return SettingsPageScaffold(
      title: t.discovery,
      children: [
        ExpressiveSection(
          title: t.discovery,
          children: [
            SettingTile(
              icon: Icons.wifi_rounded,
              title: t.lanTitle,
              subtitle: t.lanSubtitle,
              trailing: Switch(
                value: config.lanDiscovery,
                onChanged: notifier.toggleLanDiscovery,
              ),
            ),
            SettingTile(
              icon: Icons.public_rounded,
              title: t.dhtTitle,
              subtitle: t.dhtSubtitle,
              trailing: Switch(
                value: config.dhtDiscovery,
                onChanged: notifier.toggleDhtDiscovery,
              ),
            ),
            SettingTile(
              icon: Icons.router_rounded,
              title: t.portMappingTitle,
              subtitle: t.portMappingSubtitle,
              trailing: Switch(
                value: config.portMapping,
                onChanged: notifier.togglePortMapping,
              ),
            ),
            SettingTile(
              icon: Icons.hub_rounded,
              title: t.peerRelayTitle,
              subtitle: t.peerRelaySubtitle,
              trailing: Switch(
                value: config.peerRelay,
                onChanged: notifier.togglePeerRelay,
              ),
            ),
            SettingTile(
              icon: Icons.bolt_rounded,
              title: t.holePunchTitle,
              subtitle: t.holePunchSubtitle,
              trailing: Switch(
                value: config.holePunch,
                onChanged: notifier.toggleHolePunch,
              ),
            ),
            SettingTile(
              icon: Icons.bluetooth_rounded,
              title: t.bluetoothTitle,
              subtitle: t.bluetoothSubtitle,
              trailing: Switch(
                value: config.bluetoothDiscovery,
                onChanged: notifier.toggleBluetoothDiscovery,
              ),
            ),
            if (Platform.isAndroid) ...[
              SettingTile(
                icon: Icons.wifi_tethering_rounded,
                title: t.wifiDirectTitle,
                subtitle: t.wifiDirectSubtitle,
                trailing: Switch(
                  value: config.wifiDirectDiscovery,
                  onChanged: notifier.toggleWifiDirect,
                ),
              ),
              SettingTile(
                icon: Icons.cell_tower_rounded,
                title: t.wifiAwareTitle,
                subtitle: t.wifiAwareSubtitle,
                trailing: Switch(
                  value: config.wifiAwareDiscovery,
                  onChanged: notifier.toggleWifiAware,
                ),
              ),
              SettingTile(
                icon: Icons.router_rounded,
                title: t.hotspotTitle,
                subtitle: t.hotspotSubtitle,
                trailing: Switch(
                  value: config.hotspotFallback,
                  onChanged: notifier.toggleHotspot,
                ),
              ),
              if (config.hotspotFallback) const _HotspotCreateButton(),
            ],
            if (Platform.isIOS || Platform.isMacOS)
              SettingTile(
                icon: Icons.devices_rounded,
                title: t.multipeerTitle,
                subtitle: t.multipeerSubtitle,
                trailing: Switch(
                  value: config.multipeerDiscovery,
                  onChanged: notifier.toggleMultipeer,
                ),
              ),
            if (Platform.isAndroid || Platform.isIOS)
              SettingTile(
                icon: Icons.nfc_rounded,
                title: t.nfcTitle,
                subtitle: t.nfcSubtitle,
                trailing: Switch(
                  value: config.nfcPairing,
                  onChanged: notifier.toggleNfc,
                ),
              ),
            SettingTile(
              icon: Icons.sync_rounded,
              title: t.backgroundTitle,
              subtitle: t.backgroundSubtitle,
              trailing: Switch(
                value: config.syncInBackground,
                onChanged: notifier.toggleBackground,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HotspotCreateButton extends StatelessWidget {
  const _HotspotCreateButton();

  @override
  Widget build(BuildContext context) {
    final t = context.t.settings;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: M3EButton.icon(
          onPressed: () => _create(context),
          icon: const Icon(Icons.add_rounded),
          label: Text(t.hotspotCreate),
          style: .tonal,
          size: .sm,
        ),
      ),
    );
  }

  Future<void> _create(BuildContext context) async {
    final t = context.t.settings;
    await [Permission.nearbyWifiDevices, Permission.location].request();
    try {
      final credentials = await const HotspotController().start();
      if (!context.mounted || credentials == null) return;
      context.showSnackBar(
        '${t.hotspotActive(ssid: credentials.ssid)}\n'
        '${t.hotspotPassword(password: credentials.passphrase)}',
      );
    } on Object {
      if (context.mounted) context.showSnackBar(t.hotspotFailed);
    }
  }
}
