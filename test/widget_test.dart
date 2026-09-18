import 'package:flutter_test/flutter_test.dart';
import 'package:desk_pilot_f/main.dart';

void main() {
  testWidgets('App renders DeskPilotF', (WidgetTester tester) async {
    await tester.pumpWidget(const DeskPilotApp());
    expect(find.text('DeskPilotF'), findsOneWidget);
  });
}
