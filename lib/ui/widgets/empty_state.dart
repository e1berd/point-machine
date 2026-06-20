import 'package:declar_ui/declar_ui.dart';

import 'expressive.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: ExpressiveReveal(
        child: Column(
          mainAxisSize: .min,
          children: [
            AnimatedContainer(
              duration: expressiveDuration,
              curve: expressiveCurve,
              width: 96,
              height: 88,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(icon, size: 40, color: colors.onPrimaryContainer),
            ),
            const SizedBox(height: 20),
            Text(
              title,
            ).size(19).weight(.w800).color(colors.onSurface).align(.center),
            if (message != null)
              Text(message!)
                  .size(14)
                  .color(colors.onSurfaceVariant)
                  .align(.center)
                  .padding(top: 8),
            if (action != null) action!.padding(top: 24),
          ],
        ).padding(horizontal: 48),
      ),
    );
  }
}
