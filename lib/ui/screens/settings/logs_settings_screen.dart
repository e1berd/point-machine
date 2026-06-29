import 'package:declar_ui/declar_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../i18n/strings.g.dart';
import '../../../state/activity_log_provider.dart';
import '../../widgets/expressive.dart';
import 'settings_page_scaffold.dart';

class LogsSettingsScreen extends ConsumerWidget {
  const LogsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final path = ref.watch(activityLogPathProvider);
    final controller = ref.read(activityLogControllerProvider);
    final t = context.t.settings;

    return SettingsPageScaffold(
      title: t.logsTitle,
      children: [
        ExpressiveSection(
          title: t.logsTitle,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    t.logPath,
                  ).size(12).weight(.w700).color(colors.onSurfaceVariant),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      path.value ?? '...',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ).size(12).color(colors.onSurface),
                  ),
                  const SizedBox(height: 14),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 430;
                      final actions = [
                        _LogAction(
                          icon: Icons.edit_rounded,
                          label: t.changeLogPath,
                          onPressed: () async {
                            final selected = await controller.choosePath(
                              dialogTitle: t.changeLogPath,
                            );
                            if (selected != null && context.mounted) {
                              context.showSnackBar(t.logPathChanged);
                            }
                          },
                        ),
                        _LogAction(
                          icon: Icons.folder_open_rounded,
                          label: t.openLogLocation,
                          onPressed: () async {
                            final opened = await controller.openLocation();
                            if (!opened && context.mounted) {
                              context.showSnackBar(t.logOpenFailed);
                            }
                          },
                        ),
                        _LogAction(
                          icon: Icons.delete_sweep_rounded,
                          label: t.clearLogs,
                          onPressed: () async {
                            await controller.clear();
                            if (context.mounted) {
                              context.showSnackBar(t.logsCleared);
                            }
                          },
                        ),
                      ];

                      if (compact) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: 8,
                          children: [
                            for (final action in actions)
                              _LogActionButton(action: action),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          for (var i = 0; i < actions.length; i++) ...[
                            if (i > 0) const SizedBox(width: 8),
                            Expanded(
                              child: _LogActionButton(action: actions[i]),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LogAction {
  const _LogAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
}

class _LogActionButton extends StatelessWidget {
  const _LogActionButton({required this.action});

  final _LogAction action;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: action.onPressed,
      icon: Icon(action.icon),
      label: Text(action.label, maxLines: 1, overflow: TextOverflow.ellipsis),
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 14),
      ),
    );
  }
}
