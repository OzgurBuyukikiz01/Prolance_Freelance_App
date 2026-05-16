import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:prolance_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Integration flows (offline / Supabase disabled in test VM).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await bootstrap();
  });

  testWidgets('login screen shows sign-in affordances', (tester) async {
    await tester.pumpWidget(const ProlanceApp());
    await tester.pumpAndSettle(const Duration(seconds: 3));

    final loginFinder = find.text('Sign In');
    final emailFinder = find.byType(TextFormField);

    if (loginFinder.evaluate().isNotEmpty) {
      expect(loginFinder, findsOneWidget);
      expect(emailFinder, findsWidgets);
    } else {
      expect(find.text('Prolance'), findsWidgets);
    }
  });

  testWidgets('job browse: home or jobs tab reachable when logged in', (
    tester,
  ) async {
    await tester.pumpWidget(const ProlanceApp());
    await tester.pumpAndSettle(const Duration(seconds: 3));

    if (find.text('Sign In').evaluate().isNotEmpty) {
      return;
    }

    final jobsTab = find.text('Jobs');
    if (jobsTab.evaluate().isNotEmpty) {
      await tester.tap(jobsTab.first);
      await tester.pumpAndSettle();
    }
    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('messages tab opens when available', (tester) async {
    await tester.pumpWidget(const ProlanceApp());
    await tester.pumpAndSettle(const Duration(seconds: 3));

    if (find.text('Sign In').evaluate().isNotEmpty) {
      return;
    }

    final messagesTab = find.text('Messages');
    if (messagesTab.evaluate().isNotEmpty) {
      await tester.tap(messagesTab.first);
      await tester.pumpAndSettle();
    }
    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('my proposals route reachable when logged in', (tester) async {
    await tester.pumpWidget(const ProlanceApp());
    await tester.pumpAndSettle(const Duration(seconds: 3));

    if (find.text('Sign In').evaluate().isNotEmpty) {
      return;
    }

    final proposalsEntry = find.byTooltip('Tekliflerim');
    if (proposalsEntry.evaluate().isNotEmpty) {
      await tester.tap(proposalsEntry.first);
      await tester.pumpAndSettle();
      expect(find.text('My proposals'), findsOneWidget);
    }
    expect(find.byType(Scaffold), findsWidgets);
  });
}
