import 'package:declar_ui/declar_ui.dart';

import '../../../i18n/strings.g.dart';
import '../../widgets/expressive.dart';
import '../../widgets/schedule_controls.dart';

class SyncSettingsScreen extends StatelessWidget {
  const SyncSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold()
        .appBar(AppBar(title: Text(context.t.settings.syncTitle).weight(.w800)))
        .body(
          SafeArea(
            top: false,
            child: SingleChildScrollView(
              clipBehavior: Clip.hardEdge,
              child: ExpressiveResponsiveCenter(
                maxWidth: 760,
                child: ExpressiveReveal(child: const ScheduleControls()),
              ),
            ),
          ),
        );
  }
}
