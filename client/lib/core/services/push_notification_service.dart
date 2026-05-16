import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';

/// Background FCM handler (top-level required by Firebase).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

/// Registers FCM, syncs token to [profiles.fcm_token], shows foreground banners.
class PushNotificationService {
  PushNotificationService._();

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static bool get _isAutomatedTest {
    try {
      return WidgetsBinding.instance.runtimeType
          .toString()
          .contains('AutomatedTest');
    } catch (_) {
      return false;
    }
  }

  /// Safe to call from [bootstrap]; no-ops on web, tests, or missing Firebase config.
  static Future<void> initializeIfEnabled() async {
    if (_initialized || kIsWeb || _isAutomatedTest) return;
    if (!SupabaseConfig.isEnabled) return;
    if (!(Platform.isAndroid || Platform.isIOS)) return;

    try {
      await Firebase.initializeApp();
    } catch (e, st) {
      debugPrint('PushNotificationService: Firebase init skipped ($e)');
      debugPrint('$st');
      return;
    }

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidInit,
        iOS: darwinInit,
        macOS: darwinInit,
      ),
    );

    final messaging = FirebaseMessaging.instance;
    try {
      await messaging.requestPermission();
    } catch (e) {
      debugPrint('PushNotificationService: permission request failed ($e)');
    }

    await _syncToken(messaging);

    messaging.onTokenRefresh.listen((token) async {
      await _persistToken(token);
    });

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);

    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      if (event.session != null) {
        unawaited(_syncToken(messaging));
      }
    });

    _initialized = true;
  }

  static Future<void> _syncToken(FirebaseMessaging messaging) async {
    try {
      final token = await messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await _persistToken(token);
      }
    } catch (e) {
      debugPrint('PushNotificationService: getToken failed ($e)');
    }
  }

  static Future<void> _persistToken(String token) async {
    try {
      final client = Supabase.instance.client;
      final uid = client.auth.currentUser?.id;
      if (uid == null) return;
      await client.from('profiles').update({'fcm_token': token}).eq('id', uid);
    } catch (e) {
      debugPrint('PushNotificationService: token upsert failed ($e)');
    }
  }

  static Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'prolance_default',
      'Prolance',
      channelDescription: 'Prolance notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const darwinDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
    );
  }
}
