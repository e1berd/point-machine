import 'package:declar_ui/declar_ui.dart';

import '../widgets/empty_state.dart';

class FoldersScreen extends StatelessWidget {
  const FoldersScreen({super.key});

  @override
  Widget build(BuildContext context) => const EmptyState(
        icon: Icons.create_new_folder_rounded,
        title: 'No shared folders',
        message: 'Add a folder and choose which devices it syncs with.',
      );
}
