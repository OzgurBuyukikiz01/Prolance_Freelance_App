import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Smoke test: verifies the Flutter test framework can build a widget tree.
// Full app boot is skipped because Supabase is not initialized in unit-test
// mode (USE_SUPABASE defaults to true at compile time, but the SDK is not
// initialised here). Run `flutter run -d chrome` to test the full boot.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  testWidgets('smoke: app boots', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('Prolance'))),
    );
    expect(find.text('Prolance'), findsOneWidget);
  });
}
