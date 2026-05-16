class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.jobId,
    required this.reviewerId,
    required this.revieweeId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.reviewerName = '',
    this.reviewerAvatar = '',
  });

  final String id;
  final String jobId;
  final String reviewerId;
  final String revieweeId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  /// Populated via a join / separate profiles query.
  final String reviewerName;
  final String reviewerAvatar;

  factory ReviewModel.fromRow(Map<String, dynamic> row) {
    return ReviewModel(
      id: '${row['id']}',
      jobId: '${row['job_id']}',
      reviewerId: '${row['reviewer_id']}',
      revieweeId: '${row['reviewee_id']}',
      rating: (row['rating'] as num?)?.toInt() ?? 0,
      comment: '${row['comment'] ?? ''}',
      createdAt: DateTime.tryParse('${row['created_at']}') ?? DateTime.now(),
      reviewerName:
          (row['reviewer'] as Map<String, dynamic>?)?['full_name'] as String? ??
              '',
      reviewerAvatar:
          (row['reviewer'] as Map<String, dynamic>?)?['avatar_url'] as String? ??
              '',
    );
  }
}
