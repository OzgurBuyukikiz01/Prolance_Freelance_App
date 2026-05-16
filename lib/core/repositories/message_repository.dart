import 'package:flutter/foundation.dart';

import '../models/message_model.dart';

/// Messaging abstraction — swap [LocalMessageRepository] with Supabase later.
abstract class MessageRepository extends ChangeNotifier {
  List<Conversation> get conversations;

  int get totalUnreadCount;

  void removeConversation(String id);

  void markConversationRead(String id);

  /// Stable id: `job_<jobId>`. Inserts at top when new.
  String ensureConversationForJob({
    required String jobId,
    required String employerName,
    required String employerAvatar,
    bool employerOnline = false,
  });

  void recordOutboundPreview(String conversationId, String previewText);
}

class LocalMessageRepository extends MessageRepository {
  LocalMessageRepository()
      : _items = List<Conversation>.from(Conversation.dummyList());

  final List<Conversation> _items;

  @override
  List<Conversation> get conversations => List.unmodifiable(_items);

  @override
  int get totalUnreadCount =>
      _items.fold<int>(0, (sum, c) => sum + c.unreadCount);

  @override
  void removeConversation(String id) {
    _items.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  @override
  void markConversationRead(String id) {
    final i = _items.indexWhere((c) => c.id == id);
    if (i < 0) return;
    if (_items[i].unreadCount == 0) return;
    _items[i] = _items[i].copyWith(unreadCount: 0);
    notifyListeners();
  }

  @override
  String ensureConversationForJob({
    required String jobId,
    required String employerName,
    required String employerAvatar,
    bool employerOnline = false,
  }) {
    final id = 'job_$jobId';
    final existing = _items.indexWhere((c) => c.id == id);
    if (existing >= 0) return id;
    _items.insert(
      0,
      Conversation(
        id: id,
        userName: employerName,
        userAvatar: employerAvatar,
        lastMessage: 'Tap to send a message about your proposal.',
        lastMessageTime: DateTime.now(),
        unreadCount: 0,
        isOnline: employerOnline,
      ),
    );
    notifyListeners();
    return id;
  }

  @override
  void recordOutboundPreview(String conversationId, String previewText) {
    final i = _items.indexWhere((c) => c.id == conversationId);
    if (i < 0) return;
    final updated = _items.removeAt(i).copyWith(
      lastMessage: previewText,
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
    );
    _items.insert(0, updated);
    notifyListeners();
  }
}
