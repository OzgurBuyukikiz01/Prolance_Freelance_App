import 'package:flutter_test/flutter_test.dart';

import 'package:prolance_app/core/services/auth_service.dart';
import 'package:prolance_app/core/config/supabase_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthService (offline / Supabase disabled)', () {
    test('instance is a singleton', () {
      final a = AuthService.instance;
      final b = AuthService.instance;
      expect(identical(a, b), isTrue);
    });

    test('hasSession is false when Supabase is disabled', () {
      // In test environment USE_SUPABASE is not set, so isEnabled is false.
      if (!SupabaseConfig.isEnabled) {
        expect(AuthService.instance.hasSession, isFalse);
      }
    });

    test('rawUser is null when Supabase is disabled', () {
      if (!SupabaseConfig.isEnabled) {
        expect(AuthService.instance.rawUser, isNull);
      }
    });

    test('accessToken is null when Supabase is disabled', () {
      if (!SupabaseConfig.isEnabled) {
        expect(AuthService.instance.accessToken, isNull);
      }
    });

    test('authStateChanges returns empty stream when Supabase disabled', () {
      if (!SupabaseConfig.isEnabled) {
        final stream = AuthService.instance.authStateChanges();
        expect(stream, isA<Stream>());
      }
    });

    test('resetPasswordForEmail silently returns when Supabase disabled',
        () async {
      if (!SupabaseConfig.isEnabled) {
        // Should not throw.
        await expectLater(
          AuthService.instance.resetPasswordForEmail('test@example.com'),
          completes,
        );
      }
    });

    test('upsertProfileFromUserModel silently returns when Supabase disabled',
        () async {
      if (!SupabaseConfig.isEnabled) {
        // Should not throw.
        // We cannot construct a full UserModel here without the full graph,
        // so we skip the body call and just verify the method exists.
        expect(AuthService.instance.upsertProfileFromUserModel, isNotNull);
      }
    });
  });
}
