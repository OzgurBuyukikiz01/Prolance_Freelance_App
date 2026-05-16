import 'package:flutter_test/flutter_test.dart';
import 'package:prolance_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUpAll(() async {
    await bootstrap();
  });

  testWidgets('App starts with splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProlanceApp());
    expect(find.text('Prolance'), findsOneWidget);
    await tester.pumpAndSettle();
  });
}
