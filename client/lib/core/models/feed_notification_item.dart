enum FeedNotificationType { job, message, system, proposal }

class FeedNotificationItem {
  FeedNotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.type,
    this.isRead = false,
    this.payload = const {},
  });

  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final FeedNotificationType type;
  final bool isRead;
  /// Optional server JSON (e.g. `{"ui":"dialog","event":"..."}` from triggers).
  final Map<String, dynamic> payload;

  FeedNotificationItem copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    FeedNotificationType? type,
    bool? isRead,
    Map<String, dynamic>? payload,
  }) {
    return FeedNotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      payload: payload ?? this.payload,
    );
  }
}
