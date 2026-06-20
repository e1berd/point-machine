import 'package:declar_ui/declar_ui.dart';

import '../widgets/empty_state.dart';

class PairScreen extends StatelessWidget {
  const PairScreen({super.key});

  @override
  Widget build(BuildContext context) => const EmptyState(
        icon: Icons.qr_code_scanner_rounded,
        title: 'Pair a device',
        message: 'Scan a code or share yours to exchange identities offline.',
      );
}
