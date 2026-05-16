import 'package:flutter_test/flutter_test.dart';
import 'package:prolance_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Smoke test (runs with `flutter test test/smoke/`).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUpAll(() async {
    await bootstrap();
  });

  testWidgets('smoke: app boots', (tester) async {
    await tester.pumpWidget(const ProlanceApp());
    expect(find.text('Prolance'), findsWidgets);
    await tester.pumpAndSettle();
  });
}
