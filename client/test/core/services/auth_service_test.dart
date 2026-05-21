import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prolance_app/core/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test('supports Apple OAuth on iOS', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    expect(AuthService.instance.supportsAppleOAuth, isTrue);
  });

  test('supports Apple OAuth on macOS', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    expect(AuthService.instance.supportsAppleOAuth, isTrue);
  });

  test('does not support Apple OAuth on Android', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    expect(AuthService.instance.supportsAppleOAuth, isFalse);
  });
}
