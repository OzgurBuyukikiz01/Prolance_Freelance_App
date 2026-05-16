import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/feed_notification_item.dart';

/// Manages in-app notifications sourced from `public.notifications` via
/// Supabase Realtime. Falls back to an empty list when Supabase is disabled.
class NotificationRepository extends ChangeNotifier {
  NotificationRepository() {
    if (SupabaseConfig.isEnabled) {
      _subscribe();
    }
  }

  SupabaseClient? get _client {
    if (!SupabaseConfig.isEnabled) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  final List<FeedNotificationItem> _items = [];
  RealtimeChannel? _channel;

  /// Emits only newly-received realtime notifications (not the initial load).
  /// Useful for showing overlay banners.
  final StreamController<FeedNotificationItem> _newItemsController =
      StreamController<FeedNotificationItem>.broadcast();

  List<FeedNotificationItem> get items => List.unmodifiable(_items);

  int get unreadCount => _items.where((n) => !n.isRead).length;

  /// A broadcast stream that emits each notification the moment it arrives
  /// via Supabase Realtime (skips items loaded on startup).
  Stream<FeedNotificationItem> get newItems => _newItemsController.stream;

  void _subscribe() {
    final c = _client;
    if (c == null) return;

    final uid = c.auth.currentUser?.id;
    if (uid == null) return;

    // Load existing notifications.
    _loadInitial(c, uid);

    // Subscribe to real-time inserts.
    _channel = c
        .channel('notifications:$uid')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'profile_id',
            value: uid,
          ),
          callback: (payload) {
            final row = payload.newRecord;
            if (row.isEmpty) return;
            final item = _rowToItem(row);
            _items.insert(0, item);
            // Emit on the newItems stream so toast listeners are notified.
            if (!_newItemsController.isClosed) {
              _newItemsController.add(item);
            }
            notifyListeners();
          },
        )
        .subscribe();
  }

  Future<void> _loadInitial(SupabaseClient c, String uid) async {
    try {
      final rows = await c
          .from('notifications')
          .select()
          .eq('profile_id', uid)
          .order('created_at', ascending: false)
          .limit(50);

      _items
        ..clear()
        ..addAll(rows.map(_rowToItem));
      notifyListeners();
    } catch (e) {
      debugPrint('[NotificationRepository] load error: $e');
    }
  }

  FeedNotificationItem _rowToItem(Map<String, dynamic> row) {
    final typeStr = '${row['type'] ?? 'system'}';
    final type = FeedNotificationType.values.firstWhere(
      (t) => t.name == typeStr,
      orElse: () => FeedNotificationType.system,
    );
    return FeedNotificationItem(
      id: '${row['id']}',
      title: '${row['title'] ?? ''}',
      description: '${row['body'] ?? ''}',
      createdAt: DateTime.tryParse('${row['created_at']}') ?? DateTime.now(),
      type: type,
      isRead: row['read_at'] != null,
    );
  }

  Future<void> markAllRead() async {
    for (var i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(isRead: true);
    }
    notifyListeners();

    final c = _client;
    final uid = c?.auth.currentUser?.id;
    if (c == null || uid == null) return;

    try {
      await c
          .from('notifications')
          .update({'read_at': DateTime.now().toIso8601String()})
          .eq('profile_id', uid)
          .isFilter('read_at', null);
    } catch (e) {
      debugPrint('[NotificationRepository] markAllRead error: $e');
    }
  }

  Future<void> markRead(String id) async {
    final idx = _items.indexWhere((n) => n.id == id);
    if (idx < 0 || _items[idx].isRead) return;
    _items[idx] = _items[idx].copyWith(isRead: true);
    notifyListeners();

    final c = _client;
    if (c == null) return;
    try {
      await c
          .from('notifications')
          .update({'read_at': DateTime.now().toIso8601String()})
          .eq('id', id);
    } catch (e) {
      debugPrint('[NotificationRepository] markRead error: $e');
    }
  }

  /// Refresh subscription when auth state changes (e.g. after login).
  void refresh() {
    _channel?.unsubscribe();
    _channel = null;
    _items.clear();
    if (SupabaseConfig.isEnabled) {
      _subscribe();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    _newItemsController.close();
    super.dispose();
  }
}
