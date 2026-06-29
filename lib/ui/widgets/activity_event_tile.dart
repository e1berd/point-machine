import 'package:declar_ui/declar_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../i18n/strings.g.dart';
import '../../platform/open_path.dart';
import '../../state/folders_provider.dart';
import '../../state/sync_provider.dart';
import '../../sync/sync_event.dart';
import 'conflict_sheet.dart';
import 'm3e_options_menu.dart';

class ActivityActionSpec {
  const ActivityActionSpec({
    required this.icon,
    required this.label,
    required this.onInvoke,
  });

  final IconData icon;
  final String label;
  final VoidCallback onInvoke;
}

ActivityActionSpec? activityUsefulAction(
  BuildContext context,
  WidgetRef ref,
  SyncEvent event,
) {
  final t = context.t;
  switch (event.kind) {
    case SyncEventKind.disconnected:
      final folderId = event.folderId;
      final peerId = event.peerId;
      if (folderId == null || peerId == null) return null;
      return ActivityActionSpec(
        icon: Icons.sync_rounded,
        label: t.activity.actionReconnect,
        onInvoke: () => ref
            .read(syncControllerProvider.future)
            .then((controller) => controller.redial(folderId, peerId)),
      );
    case SyncEventKind.conflict:
      final folderId = event.folderId;
      if (folderId == null) return null;
      return ActivityActionSpec(
        icon: Icons.rule_rounded,
        label: t.activity.actionResolve,
        onInvoke: () => showConflictSheet(context, folderId),
      );
    case SyncEventKind.received:
      final folderId = event.folderId;
      if (folderId == null) return null;
      return ActivityActionSpec(
        icon: Icons.folder_open_rounded,
        label: t.activity.actionReveal,
        onInvoke: () {
          final folders = ref.read(foldersProvider).value ?? const [];
          for (final folder in folders) {
            if (folder.id == folderId) {
              openFolderInFileManager(folder.localPath);
              return;
            }
          }
        },
      );
    case SyncEventKind.connecting:
    case SyncEventKind.connected:
      return null;
  }
}

class ActivityEventMenu extends ConsumerWidget {
  const ActivityEventMenu({
    super.key,
    required this.event,
    required this.onDelete,
  });

  final SyncEvent event;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final action = activityUsefulAction(context, ref, event);
    return M3EOptionsMenu(
      tooltip: context.t.activity.options,
      actions: [
        if (action != null)
          M3EMenuAction(
            icon: action.icon,
            label: action.label,
            onSelected: action.onInvoke,
          ),
        M3EMenuAction(
          icon: Icons.delete_outline_rounded,
          label: context.t.activity.remove,
          onSelected: onDelete,
          destructive: true,
        ),
      ],
    );
  }
}

class ActivityEventTile extends ConsumerWidget {
  const ActivityEventTile({
    super.key,
    required this.event,
    required this.onDelete,
    required this.child,
  });

  final SyncEvent event;
  final VoidCallback onDelete;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final action = activityUsefulAction(context, ref, event);
    return Dismissible(
      key: ValueKey(
        '${event.kind.name}-${event.at.microsecondsSinceEpoch}-${event.path ?? ''}',
      ),
      direction: action == null
          ? DismissDirection.startToEnd
          : DismissDirection.horizontal,
      background: _swipeBackground(
        context,
        alignment: Alignment.centerLeft,
        icon: Icons.delete_rounded,
        label: context.t.activity.remove,
        container: colors.errorContainer,
        foreground: colors.onErrorContainer,
      ),
      secondaryBackground: action == null
          ? null
          : _swipeBackground(
              context,
              alignment: Alignment.centerRight,
              icon: action.icon,
              label: action.label,
              container: colors.primaryContainer,
              foreground: colors.onPrimaryContainer,
            ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) return true;
        action?.onInvoke();
        return false;
      },
      onDismissed: (_) => onDelete(),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    );
  }
}

Widget _swipeBackground(
  BuildContext context, {
  required Alignment alignment,
  required IconData icon,
  required String label,
  required Color container,
  required Color foreground,
}) {
  return Container(
    alignment: alignment,
    decoration: BoxDecoration(
      color: container,
      borderRadius: BorderRadius.circular(24),
    ),
    child: OverflowBox(
      alignment: alignment,
      minWidth: 0,
      maxWidth: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Row(
          mainAxisSize: .min,
          children: [
            Icon(icon, color: foreground),
            const SizedBox(width: 10),
            Text(label).size(14).weight(.w700).color(foreground),
          ],
        ),
      ),
    ),
  );
}
