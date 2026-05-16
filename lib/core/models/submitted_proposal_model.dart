enum SubmittedProposalStatus {
  awaitingResponse,
  accepted,
  declined,
  cancelled,
}

SubmittedProposalStatus submittedProposalStatusFromJson(String? raw) {
  switch (raw) {
    case 'accepted':
      return SubmittedProposalStatus.accepted;
    case 'declined':
      return SubmittedProposalStatus.declined;
    case 'cancelled':
      return SubmittedProposalStatus.cancelled;
    case 'awaitingResponse':
    default:
      return SubmittedProposalStatus.awaitingResponse;
  }
}

String submittedProposalStatusToJson(SubmittedProposalStatus s) {
  switch (s) {
    case SubmittedProposalStatus.awaitingResponse:
      return 'awaitingResponse';
    case SubmittedProposalStatus.accepted:
      return 'accepted';
    case SubmittedProposalStatus.declined:
      return 'declined';
    case SubmittedProposalStatus.cancelled:
      return 'cancelled';
  }
}

class SubmittedProposal {
  SubmittedProposal({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.bid,
    required this.deliveryYears,
    required this.deliveryMonths,
    required this.deliveryDays,
    required this.coverLetter,
    required this.attachmentNames,
    required this.submittedAt,
    this.status = SubmittedProposalStatus.awaitingResponse,
  });

  final String id;
  final String jobId;
  final String jobTitle;
  final double bid;
  final int deliveryYears;
  final int deliveryMonths;
  final int deliveryDays;
  final String coverLetter;
  final List<String> attachmentNames;
  final DateTime submittedAt;
  final SubmittedProposalStatus status;

  SubmittedProposal copyWith({
    SubmittedProposalStatus? status,
  }) {
    return SubmittedProposal(
      id: id,
      jobId: jobId,
      jobTitle: jobTitle,
      bid: bid,
      deliveryYears: deliveryYears,
      deliveryMonths: deliveryMonths,
      deliveryDays: deliveryDays,
      coverLetter: coverLetter,
      attachmentNames: attachmentNames,
      submittedAt: submittedAt,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'jobId': jobId,
        'jobTitle': jobTitle,
        'bid': bid,
        'deliveryYears': deliveryYears,
        'deliveryMonths': deliveryMonths,
        'deliveryDays': deliveryDays,
        'coverLetter': coverLetter,
        'attachmentNames': attachmentNames,
        'submittedAt': submittedAt.toIso8601String(),
        'status': submittedProposalStatusToJson(status),
      };

  factory SubmittedProposal.fromJson(Map<String, dynamic> json) {
    final status =
        submittedProposalStatusFromJson(json['status'] as String?);

    late final int dy;
    late final int dm;
    late final int dd;

    if (json.containsKey('deliveryYears')) {
      dy = (json['deliveryYears'] as num?)?.toInt() ?? 0;
      dm = (json['deliveryMonths'] as num?)?.toInt() ?? 0;
      dd = (json['deliveryDays'] as num?)?.toInt() ?? 0;
    } else {
      final legacy = (json['deliveryDays'] as num?)?.toInt() ?? 0;
      dy = 0;
      dm = 0;
      dd = legacy;
    }

    return SubmittedProposal(
      id: json['id'] as String,
      jobId: json['jobId'] as String,
      jobTitle: json['jobTitle'] as String? ?? '',
      bid: (json['bid'] as num?)?.toDouble() ?? 0,
      deliveryYears: dy,
      deliveryMonths: dm,
      deliveryDays: dd,
      coverLetter: json['coverLetter'] as String? ?? '',
      attachmentNames: List<String>.from(
        json['attachmentNames'] as List<dynamic>? ?? const [],
      ),
      submittedAt: DateTime.tryParse(json['submittedAt'] as String? ?? '') ??
          DateTime.now(),
      status: status,
    );
  }
}
