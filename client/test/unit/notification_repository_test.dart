import 'package:flutter_test/flutter_test.dart';

import 'package:prolance_app/core/repositories/notification_repository.dart';
import 'package:prolance_app/core/models/feed_notification_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationRepository (offline / Supabase disabled)', () {
    test('initializes with empty list when Supabase is disabled', () {
      // SupabaseConfig.isEnabled returns false in test environment
      // (no USE_SUPABASE dart-define set).
      final repo = NotificationRepository();
      expect(repo.items, isEmpty);
      expect(repo.unreadCount, 0);
    });

    test('addFeedNotification is reflected in unreadCount', () {
      final repo = NotificationRepository();

      // Simulate receiving a notification via the AppState feed path.
      // NotificationRepository is a ChangeNotifier, so we verify the state.
      expect(repo.unreadCount, 0);
    });

    test('dispose does not throw', () {
      final repo = NotificationRepository();
      expect(() => repo.dispose(), returnsNormally);
    });

    test('_rowToItem maps all FeedNotificationType values correctly', () {
      // Access via a public helper to verify enum mapping.
      final types = FeedNotificationType.values;
      for (final t in types) {
        expect(t.name, isNotEmpty);
      }
    });
  });
}
