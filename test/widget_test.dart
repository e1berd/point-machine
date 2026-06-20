import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:point_machine/app.dart';

void main() {
  testWidgets('boots into the devices destination', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PointMachineApp()));
    await tester.pumpAndSettle();

    expect(find.text('Devices'), findsWidgets);
    expect(find.text('No paired devices'), findsOneWidget);
  });
}
