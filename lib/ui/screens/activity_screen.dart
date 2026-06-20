import 'package:declar_ui/declar_ui.dart';

import '../widgets/empty_state.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) => const EmptyState(
        icon: Icons.sync_rounded,
        title: 'Nothing syncing',
        message: 'Transfers and conflicts will appear here as they happen.',
      );
}
