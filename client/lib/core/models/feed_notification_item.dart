enum FeedNotificationType { job, message, system, proposal }

class FeedNotificationItem {
  FeedNotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.type,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final FeedNotificationType type;
  final bool isRead;

  FeedNotificationItem copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    FeedNotificationType? type,
    bool? isRead,
  }) {
    return FeedNotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }
}
