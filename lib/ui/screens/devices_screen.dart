import 'package:declar_ui/declar_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3e_core/m3e_core.dart';

import '../../core/pairing.dart';
import '../../state/identity_provider.dart';
import '../../state/peers_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/expressive.dart';

class DevicesScreen extends ConsumerWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final identity = ref.watch(identityProvider);
    final name = ref.watch(deviceNameProvider);
    final peers = ref.watch(pairedPeersProvider);
    final colors = context.colors;

    return SafeArea(
      top: false,
      child: ExpressiveSwitcher(
        child: identity.when(
          loading: () => const Center(
            key: ValueKey('identity-loading'),
            child: CircularProgressIndicator(),
          ),
          error: (error, _) => EmptyState(
            key: const ValueKey('identity-error'),
            icon: Icons.error_outline_rounded,
            title: 'Could not load identity',
            message: '$error',
          ),
          data: (device) => Column(
            key: const ValueKey('identity-data'),
            crossAxisAlignment: .stretch,
            children: [
              ExpressiveReveal(
                child: M3ECardList(
                  itemCount: 1,
                  itemBuilder: (ctx, i) =>
                      _thisDevice(context, name, device.id),
                  outerRadius: 32,
                  innerRadius: 12,
                  gap: 0,
                  color: colors.surfaceContainerHigh,
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Text(
                  'Paired devices',
                ).size(12).weight(.w800).letterSpacing(0).color(colors.primary),
              ),
              Expanded(
                child: ExpressiveSwitcher(
                  child: peers.when(
                    loading: () => const Center(
                      key: ValueKey('peers-loading'),
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, _) => EmptyState(
                      key: const ValueKey('peers-error'),
                      icon: Icons.error_outline_rounded,
                      title: 'Could not load paired devices',
                      message: '$error',
                    ),
                    data: (items) {
                      if (items.isEmpty) {
                        return const EmptyState(
                          key: ValueKey('peers-empty'),
                          icon: Icons.devices_other_rounded,
                          title: 'No paired devices',
                          message: 'Open Pair to connect another device.',
                        );
                      }

                      return M3ECardList.builder(
                        key: const ValueKey('peers-list'),
                        itemCount: items.length,
                        itemBuilder: (ctx, i) =>
                            _pairedDevice(context, ref, items[i]),
                        outerRadius: 32,
                        innerRadius: 12,
                        gap: 8,
                        color: colors.surfaceContainerHigh,
                        padding: const EdgeInsets.all(16),
                        listPadding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _thisDevice(BuildContext context, String name, String id) {
    final colors = context.colors;
    return Row(
      children: [
        ExpressiveIconContainer(
          icon: Icons.computer_rounded,
          color: colors.primaryContainer,
          foregroundColor: colors.onPrimaryContainer,
        ).padding(right: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Text(name).size(16).weight(.w700),
              Text('This device').size(12).color(colors.onSurfaceVariant),
            ],
          ),
        ),
        ExpressiveStatusPill(
          icon: Icons.bolt_rounded,
          label: 'Online',
          color: colors.tertiaryContainer,
          foregroundColor: colors.onTertiaryContainer,
        ),
      ],
    );
  }

  Widget _pairedDevice(
    BuildContext context,
    WidgetRef ref,
    PairingPayload peer,
  ) {
    final colors = context.colors;

    return Row(
      children: [
        ExpressiveIconContainer(
          icon: Icons.devices_other_rounded,
          color: colors.secondaryContainer,
          foregroundColor: colors.onSecondaryContainer,
        ).padding(right: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Text(peer.name).size(16).weight(.w700),
              Text(
                peer.deviceId,
              ).size(12).color(colors.onSurfaceVariant).overflow(.ellipsis),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Remove device',
          onPressed: () =>
              ref.read(pairedPeersProvider.notifier).remove(peer.deviceId),
          icon: const Icon(Icons.delete_outline_rounded),
        ),
      ],
    );
  }
}
