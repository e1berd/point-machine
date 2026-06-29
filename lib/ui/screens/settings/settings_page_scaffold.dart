import 'package:declar_ui/declar_ui.dart';

import '../../widgets/expressive.dart';

class SettingsPageScaffold extends StatelessWidget {
  const SettingsPageScaffold({
    super.key,
    required this.title,
    required this.children,
    this.maxWidth = 760,
  });

  final String title;
  final List<Widget> children;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Scaffold()
        .appBar(AppBar(title: Text(title).weight(.w800)))
        .body(
          SafeArea(
            top: false,
            child: SingleChildScrollView(
              clipBehavior: Clip.hardEdge,
              child: ExpressiveResponsiveCenter(
                maxWidth: maxWidth,
                child: Column(
                  crossAxisAlignment: .stretch,
                  spacing: 16,
                  children: children,
                ),
              ),
            ),
          ),
        );
  }
}
