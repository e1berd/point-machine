import 'package:declar_ui/declar_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/activity_screen.dart';
import 'screens/devices_screen.dart';
import 'screens/folders_screen.dart';
import 'screens/pair_screen.dart';
import 'screens/settings_screen.dart';

class _Destination {
  const _Destination(this.icon, this.label, this.screen);

  final IconData icon;
  final String label;
  final Widget screen;
}

const _destinations = [
  _Destination(Icons.devices_rounded, 'Devices', DevicesScreen()),
  _Destination(Icons.folder_rounded, 'Folders', FoldersScreen()),
  _Destination(Icons.qr_code_rounded, 'Pair', PairScreen()),
  _Destination(Icons.sync_rounded, 'Activity', ActivityScreen()),
  _Destination(Icons.settings_rounded, 'Settings', SettingsScreen()),
];

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  void _select(int next) => setState(() => _index = next);

  @override
  Widget build(BuildContext context) {
    final active = _destinations[_index];
    final bar = AppBar(title: Text(active.label).weight(.w600));

    if (context.width >= 720) {
      return Scaffold().appBar(bar).body(
            Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: _select,
                  labelType: .all,
                  destinations: [
                    for (final d in _destinations)
                      NavigationRailDestination(
                        icon: Icon(d.icon),
                        label: Text(d.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                active.screen.expanded(),
              ],
            ),
          );
    }

    return Scaffold().appBar(bar).body(active.screen).bottomNavigation(
          NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: _select,
            destinations: [
              for (final d in _destinations)
                NavigationDestination(icon: Icon(d.icon), label: d.label),
            ],
          ),
        );
  }
}
