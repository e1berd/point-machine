import 'package:declar_ui/declar_ui.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
  });

  final IconData icon;
  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      children: [
        Icon(icon, size: 56, color: colors.primary),
        Text(title).size(20).weight(.w600),
        if (message != null)
          Text(message!).align(.center).color(colors.onSurfaceVariant),
      ],
    ).spacing(12).mainAlign(.center).crossAlign(.center).padding(all: 32).center();
  }
}
