import 'package:flutter_test/flutter_test.dart';
import 'package:prolance_app/main.dart';

void main() {
  testWidgets('App starts with splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProlanceApp());
    expect(find.text('Prolance'), findsOneWidget);
  });
}
