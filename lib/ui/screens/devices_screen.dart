import 'package:declar_ui/declar_ui.dart';

import '../widgets/empty_state.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) => const EmptyState(
        icon: Icons.devices_other_rounded,
        title: 'No paired devices',
        message: 'Pair another device to start syncing files directly, peer to peer.',
      );
}
