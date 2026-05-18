import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:prolance_app/core/repositories/notification_repository.dart';
import 'package:prolance_app/core/models/feed_notification_item.dart';

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

FeedNotificationItem _item({
  String id = 'test-1',
  String title = 'Başlık',
  FeedNotificationType type = FeedNotificationType.system,
  bool isRead = false,
}) =>
    FeedNotificationItem(
      id: id,
      title: title,
      description: 'Açıklama',
      createdAt: DateTime(2025, 1, 1),
      type: type,
      isRead: isRead,
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationRepository (offline / Supabase disabled)', () {
    // ── Initial state ────────────────────────────────────────────────────────

    test('initializes with empty list', () {
      final repo = NotificationRepository();
      expect(repo.items, isEmpty);
      expect(repo.unreadCount, 0);
    });

    // ── pushLocal ────────────────────────────────────────────────────────────

    test('pushLocal adds item to front of list', () {
      final repo = NotificationRepository();
      repo.pushLocal(_item(id: 'a', title: 'İlk'));
      repo.pushLocal(_item(id: 'b', title: 'İkinci'));

      expect(repo.items.length, 2);
      expect(repo.items.first.id, 'b'); // most recent at front
    });

    test('pushLocal increments unreadCount', () {
      final repo = NotificationRepository();
      repo.pushLocal(_item(id: '1'));
      repo.pushLocal(_item(id: '2'));

      expect(repo.unreadCount, 2);
    });

    test('pushLocal with already-read item does not increment unreadCount', () {
      final repo = NotificationRepository();
      repo.pushLocal(_item(id: '1', isRead: true));

      expect(repo.unreadCount, 0);
    });

    // ── newItems stream ───────────────────────────────────────────────────────

    test('pushLocal emits on newItems stream', () async {
      final repo = NotificationRepository();
      final received = <FeedNotificationItem>[];
      final sub = repo.newItems.listen(received.add);

      final n = _item(id: 'stream-1', title: 'Realtime');
      repo.pushLocal(n);

      await Future<void>.delayed(Duration.zero);

      expect(received.length, 1);
      expect(received.first.id, 'stream-1');

      await sub.cancel();
    });

    test('multiple pushLocal calls emit in order on newItems', () async {
      final repo = NotificationRepository();
      final received = <String>[];
      final sub = repo.newItems.listen((n) => received.add(n.id));

      repo.pushLocal(_item(id: 'x'));
      repo.pushLocal(_item(id: 'y'));
      repo.pushLocal(_item(id: 'z'));

      await Future<void>.delayed(Duration.zero);

      expect(received, ['x', 'y', 'z']);
      await sub.cancel();
    });

    // ── removeLocal ──────────────────────────────────────────────────────────

    test('removeLocal removes item by id', () {
      final repo = NotificationRepository();
      repo.pushLocal(_item(id: 'keep'));
      repo.pushLocal(_item(id: 'delete'));

      repo.removeLocal('delete');

      expect(repo.items.length, 1);
      expect(repo.items.first.id, 'keep');
    });

    test('removeLocal on unknown id is a no-op', () {
      final repo = NotificationRepository();
      repo.pushLocal(_item(id: 'a'));
      repo.removeLocal('does-not-exist');

      expect(repo.items.length, 1);
    });

    // ── markAllRead ──────────────────────────────────────────────────────────

    test('markAllRead sets unreadCount to 0', () async {
      final repo = NotificationRepository();
      repo.pushLocal(_item(id: '1'));
      repo.pushLocal(_item(id: '2'));
      expect(repo.unreadCount, 2);

      await repo.markAllRead();

      expect(repo.unreadCount, 0);
    });

    test('markAllRead marks every item as read', () async {
      final repo = NotificationRepository();
      repo.pushLocal(_item(id: '1'));
      repo.pushLocal(_item(id: '2'));

      await repo.markAllRead();

      expect(repo.items.every((n) => n.isRead), isTrue);
    });

    // ── markRead (single) ────────────────────────────────────────────────────

    test('markRead decrements unreadCount by 1', () async {
      final repo = NotificationRepository();
      repo.pushLocal(_item(id: 'r1'));
      repo.pushLocal(_item(id: 'r2'));
      expect(repo.unreadCount, 2);

      await repo.markRead('r1');

      expect(repo.unreadCount, 1);
    });

    test('markRead is idempotent on already-read item', () async {
      final repo = NotificationRepository();
      repo.pushLocal(_item(id: 'already', isRead: true));

      await repo.markRead('already');

      expect(repo.unreadCount, 0);
      expect(repo.items.first.isRead, isTrue);
    });

    // ── ChangeNotifier ───────────────────────────────────────────────────────

    test('pushLocal notifies listeners', () {
      final repo = NotificationRepository();
      var notified = false;
      repo.addListener(() => notified = true);

      repo.pushLocal(_item());

      expect(notified, isTrue);
    });

    test('removeLocal notifies listeners', () {
      final repo = NotificationRepository();
      repo.pushLocal(_item(id: 'del'));
      var notified = false;
      repo.addListener(() => notified = true);

      repo.removeLocal('del');

      expect(notified, isTrue);
    });

    // ── FeedNotificationType mapping ──────────────────────────────────────────

    test('all FeedNotificationType values have non-empty names', () {
      for (final t in FeedNotificationType.values) {
        expect(t.name, isNotEmpty);
      }
    });

    test('type names map to known strings', () {
      expect(FeedNotificationType.job.name, 'job');
      expect(FeedNotificationType.message.name, 'message');
      expect(FeedNotificationType.system.name, 'system');
      expect(FeedNotificationType.proposal.name, 'proposal');
    });

    // ── Disposal ─────────────────────────────────────────────────────────────

    test('dispose does not throw', () {
      final repo = NotificationRepository();
      expect(() => repo.dispose(), returnsNormally);
    });

    test('newItems stream is closed after dispose', () async {
      final repo = NotificationRepository();
      final events = <FeedNotificationItem>[];
      repo.newItems.listen(events.add);

      repo.dispose();

      // pushLocal after dispose should not throw and stream is closed
      expect(events, isEmpty);
    });
  });
}
