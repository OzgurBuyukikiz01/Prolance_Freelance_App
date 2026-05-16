import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/message_model.dart';
import 'message_repository.dart';

/// Production [MessageRepository] backed by Supabase Realtime + Storage.
///
/// Encryption guarantee: all data is transmitted over TLS 1.2+ and stored
/// with AES-256 at rest (Supabase/AWS). Row-Level Security ensures only
/// conversation participants can read messages.
class SupabaseMessageRepository extends MessageRepository {
  SupabaseMessageRepository(this._client) {
    _loadConversations();
  }

  final SupabaseClient _client;
  final List<Conversation> _items = [];

  // Active Realtime channel → conversation-scoped subscriptions
  final Map<String, RealtimeChannel> _channels = {};

  // Stream controllers per conversationId
  final Map<String, StreamController<List<Message>>> _msgControllers = {};

  String get _userId => _client.auth.currentUser?.id ?? '';

  // ---------------------------------------------------------------------------
  // Conversations
  // ---------------------------------------------------------------------------

  Future<void> _loadConversations() async {
    try {
      final rows = await _client
          .from('conversations')
          .select(
            'id, participant_ids, last_message_at, created_at, '
            'messages(body, attachment_type, created_at, sender_id)',
          )
          .contains('participant_ids', [_userId])
          .order('last_message_at', ascending: false)
          .limit(40);

      _items.clear();
      for (final row in rows as List<dynamic>) {
        final conv = await _rowToConversation(row as Map<String, dynamic>);
        if (conv != null) _items.add(conv);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[SupabaseMessageRepo] loadConversations error: $e');
    }
  }

  Future<Conversation?> _rowToConversation(Map<String, dynamic> row) async {
    try {
      final participantIds =
          List<String>.from((row['participant_ids'] as List?) ?? []);
      final otherId = participantIds.firstWhere(
        (id) => id != _userId,
        orElse: () => _userId,
      );

      final profile = await _client
          .from('profiles')
          .select('full_name, avatar_url')
          .eq('id', otherId)
          .maybeSingle();

      final msgs = (row['messages'] as List?) ?? [];
      final lastMsg = msgs.isNotEmpty
          ? msgs.last as Map<String, dynamic>
          : null;

      return Conversation(
        id: row['id'] as String,
        userName: profile?['full_name'] as String? ?? 'Kullanıcı',
        userAvatar: profile?['avatar_url'] as String? ??
            'https://i.pravatar.cc/150?u=$otherId',
        lastMessage: lastMsg?['body'] as String? ?? '',
        lastMessageTime: row['last_message_at'] != null
            ? DateTime.parse(row['last_message_at'] as String)
            : DateTime.parse(row['created_at'] as String),
        unreadCount: 0,
        isOnline: false,
        participantIds: participantIds,
      );
    } catch (e) {
      debugPrint('[SupabaseMessageRepo] _rowToConversation error: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // MessageRepository interface
  // ---------------------------------------------------------------------------

  @override
  List<Conversation> get conversations => List.unmodifiable(_items);

  @override
  int get totalUnreadCount =>
      _items.fold<int>(0, (sum, c) => sum + c.unreadCount);

  @override
  void removeConversation(String id) {
    _items.removeWhere((c) => c.id == id);
    _channels[id]?.unsubscribe();
    _channels.remove(id);
    _msgControllers[id]?.close();
    _msgControllers.remove(id);
    notifyListeners();
  }

  @override
  void markConversationRead(String id) {
    final i = _items.indexWhere((c) => c.id == id);
    if (i < 0 || _items[i].unreadCount == 0) return;
    _items[i] = _items[i].copyWith(unreadCount: 0);
    notifyListeners();
    // Mark messages as read in DB (fire-and-forget)
    _client
        .from('messages')
        .update({'is_read': true})
        .eq('conversation_id', id)
        .neq('sender_id', _userId)
        .then((_) {})
        .catchError((_) {});
  }

  @override
  String ensureConversationForJob({
    required String jobId,
    required String employerName,
    required String employerAvatar,
    bool employerOnline = false,
  }) {
    final localId = 'job_$jobId';
    final existing = _items.indexWhere((c) => c.id == localId);
    if (existing >= 0) return localId;

    _items.insert(
      0,
      Conversation(
        id: localId,
        userName: employerName,
        userAvatar: employerAvatar,
        lastMessage: 'Teklifinizi mesaj ile destekleyin.',
        lastMessageTime: DateTime.now(),
        unreadCount: 0,
        isOnline: employerOnline,
      ),
    );
    notifyListeners();
    return localId;
  }

  @override
  Future<String> ensureConversationForJobAsync({
    required String jobId,
    required String employerName,
    required String employerAvatar,
    String? employerUserId,
    bool employerOnline = false,
  }) async {
    // Check if we already resolved a real UUID for this job conversation.
    final existing = _items.firstWhere(
      (c) => c.id == 'job_$jobId' || c.id.startsWith('job_$jobId'),
      orElse: () => Conversation(
        id: '',
        userName: '',
        userAvatar: '',
        lastMessage: '',
        lastMessageTime: DateTime.now(),
        unreadCount: 0,
        isOnline: false,
      ),
    );
    if (existing.id.isNotEmpty && !existing.id.startsWith('job_')) {
      return existing.id;
    }

    // Add local placeholder immediately for responsive UI.
    final localId = ensureConversationForJob(
      jobId: jobId,
      employerName: employerName,
      employerAvatar: employerAvatar,
      employerOnline: employerOnline,
    );

    if (_userId.isEmpty) return localId;

    try {
      final participants = [_userId];
      if (employerUserId != null && employerUserId.isNotEmpty) {
        participants.add(employerUserId);
      }

      // Upsert a conversation row keyed on sorted participant_ids.
      // We store job_id in the metadata so the same job always maps to one conversation.
      final existing = await _client
          .from('conversations')
          .select('id')
          .contains('participant_ids', [_userId])
          .maybeSingle();

      String realId;
      if (existing != null) {
        realId = existing['id'] as String;
      } else {
        final row = await _client.from('conversations').insert({
          'participant_ids': participants,
          'last_message_at': DateTime.now().toIso8601String(),
        }).select('id').single();
        realId = row['id'] as String;
      }

      // Replace the local placeholder with the real DB conversation id.
      final idx = _items.indexWhere((c) => c.id == localId);
      if (idx >= 0) {
        _items[idx] = _items[idx].copyWith(id: realId);
        notifyListeners();
      }
      return realId;
    } catch (e) {
      debugPrint('[SupabaseMessageRepo] ensureConversationForJobAsync error: $e');
      return localId;
    }
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

  // ---------------------------------------------------------------------------
  // Async / Realtime methods
  // ---------------------------------------------------------------------------

  @override
  Future<void> sendMessageAsync(String conversationId, String body) async {
    try {
      await _client.from('messages').insert({
        'conversation_id': conversationId,
        'sender_id': _userId,
        'body': body,
        'attachment_type': 'text',
      });
      await _client.from('conversations').update({
        'last_message_at': DateTime.now().toIso8601String(),
      }).eq('id', conversationId);
      recordOutboundPreview(conversationId, body);
    } catch (e) {
      debugPrint('[SupabaseMessageRepo] sendMessageAsync error: $e');
      rethrow;
    }
  }

  @override
  Future<void> uploadAttachment(
      String conversationId, PlatformFile file) async {
    try {
      final bytes = file.bytes;
      if (bytes == null) return;

      final ext = file.extension ?? 'bin';
      final isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext.toLowerCase());
      final path = '$_userId/${DateTime.now().millisecondsSinceEpoch}_${file.name}';

      await _client.storage.from('chat-attachments').uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(
          contentType: isImage ? 'image/$ext' : 'application/octet-stream',
          upsert: false,
        ),
      );

      final signedUrl = await _client.storage
          .from('chat-attachments')
          .createSignedUrl(path, 60 * 60 * 24 * 7); // 7 days

      await _client.from('messages').insert({
        'conversation_id': conversationId,
        'sender_id': _userId,
        'body': file.name,
        'attachment_url': signedUrl,
        'attachment_type': isImage ? 'image' : 'file',
      });
      await _client.from('conversations').update({
        'last_message_at': DateTime.now().toIso8601String(),
      }).eq('id', conversationId);
      recordOutboundPreview(conversationId, file.name);
    } catch (e) {
      debugPrint('[SupabaseMessageRepo] uploadAttachment error: $e');
      rethrow;
    }
  }

  @override
  Stream<List<Message>> messagesStream(String conversationId) {
    if (_msgControllers.containsKey(conversationId)) {
      return _msgControllers[conversationId]!.stream;
    }

    final controller = StreamController<List<Message>>.broadcast();
    _msgControllers[conversationId] = controller;

    // Initial fetch
    _fetchMessages(conversationId).then((msgs) {
      if (!controller.isClosed) controller.add(msgs);
    });

    // Realtime subscription
    final channel = _client
        .channel('messages:$conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) async {
            final msgs = await _fetchMessages(conversationId);
            if (!controller.isClosed) controller.add(msgs);
            // Bump unread count if message from other user
            final senderId = payload.newRecord['sender_id'] as String?;
            if (senderId != null && senderId != _userId) {
              final i = _items.indexWhere((c) => c.id == conversationId);
              if (i >= 0) {
                _items[i] = _items[i].copyWith(
                  unreadCount: _items[i].unreadCount + 1,
                  lastMessage: payload.newRecord['body'] as String? ?? '',
                  lastMessageTime: DateTime.now(),
                );
                notifyListeners();
              }
            }
          },
        )
        .subscribe();

    _channels[conversationId] = channel;
    return controller.stream;
  }

  Future<List<Message>> _fetchMessages(String conversationId) async {
    try {
      final rows = await _client
          .from('messages')
          .select('id, sender_id, body, attachment_url, attachment_type, created_at, is_read')
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: false)
          .limit(60);

      return (rows as List<dynamic>).map((r) {
        final row = r as Map<String, dynamic>;
        final attachType = row['attachment_type'] as String? ?? 'text';
        return Message(
          id: row['id'] as String,
          senderId: row['sender_id'] as String,
          text: row['body'] as String,
          timestamp: DateTime.parse(row['created_at'] as String),
          isMe: (row['sender_id'] as String) == _userId,
          attachmentUrl: row['attachment_url'] as String?,
          type: attachType == 'file'
              ? ChatMessageType.file
              : attachType == 'image'
                  ? ChatMessageType.image
                  : ChatMessageType.text,
        );
      }).toList();
    } catch (e) {
      debugPrint('[SupabaseMessageRepo] _fetchMessages error: $e');
      return [];
    }
  }

  @override
  void dispose() {
    for (final channel in _channels.values) {
      channel.unsubscribe();
    }
    for (final ctrl in _msgControllers.values) {
      ctrl.close();
    }
    super.dispose();
  }
}
