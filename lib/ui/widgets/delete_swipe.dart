import 'package:declar_ui/declar_ui.dart';

Widget deleteSwipeBackground(
  BuildContext context,
  Alignment alignment,
  String label,
) {
  final colors = context.colors;
  return Container(
    alignment: alignment,
    decoration: BoxDecoration(
      color: colors.errorContainer,
      borderRadius: BorderRadius.circular(32),
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
            Icon(Icons.delete_rounded, color: colors.onErrorContainer),
            const SizedBox(width: 10),
            Text(label).size(14).weight(.w700).color(colors.onErrorContainer),
          ],
        ),
      ),
    ),
  );
}
