/// Supabase `proposals.lifecycle_phase` (subset used in UI).
abstract class ProposalLifecycle {
  ProposalLifecycle._();

  static const String submitted = 'submitted';
  static const String escrowFunded = 'escrow_funded';
  /// Freelancer confirmed files; client may download and accept/decline.
  static const String awaitingClientReview = 'awaiting_client_review';
  /// Legacy phase (treated like [awaitingClientReview] in DB after migration).
  static const String delivered = 'delivered';
  static const String payoutPending = 'payout_pending';
  static const String closed = 'closed';
  static const String disputed = 'disputed';
}

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
    case 'rejected':
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
    this.lifecyclePhase = ProposalLifecycle.submitted,
    this.fundedAmountCents,
    this.freelancerPayoutCents,
    this.deliveryDisputeDeadline,
    this.payoutFinalized = false,
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
  final String lifecyclePhase;
  final int? fundedAmountCents;
  final int? freelancerPayoutCents;
  final DateTime? deliveryDisputeDeadline;
  final bool payoutFinalized;

  /// Combined label for list chips (freelancer My proposals).
  String get workflowLabel {
    if (status == SubmittedProposalStatus.cancelled) return 'Withdrawn';
    if (status == SubmittedProposalStatus.declined) return 'Declined';
    if (status == SubmittedProposalStatus.awaitingResponse) return 'Waiting';
    switch (lifecyclePhase) {
      case ProposalLifecycle.escrowFunded:
        return 'In escrow · upload files';
      case ProposalLifecycle.awaitingClientReview:
      case ProposalLifecycle.delivered:
        return 'With client · review';
      case ProposalLifecycle.payoutPending:
        return 'Payout pending (24h)';
      case ProposalLifecycle.closed:
        return 'Completed';
      case ProposalLifecycle.disputed:
        return 'Disputed';
      default:
        return status == SubmittedProposalStatus.accepted ? 'Accepted' : 'Waiting';
    }
  }

  SubmittedProposal copyWith({
    String? id,
    SubmittedProposalStatus? status,
    String? lifecyclePhase,
    int? fundedAmountCents,
    int? freelancerPayoutCents,
    DateTime? deliveryDisputeDeadline,
    bool? payoutFinalized,
  }) {
    return SubmittedProposal(
      id: id ?? this.id,
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
      lifecyclePhase: lifecyclePhase ?? this.lifecyclePhase,
      fundedAmountCents: fundedAmountCents ?? this.fundedAmountCents,
      freelancerPayoutCents:
          freelancerPayoutCents ?? this.freelancerPayoutCents,
      deliveryDisputeDeadline:
          deliveryDisputeDeadline ?? this.deliveryDisputeDeadline,
      payoutFinalized: payoutFinalized ?? this.payoutFinalized,
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
        'lifecyclePhase': lifecyclePhase,
        'fundedAmountCents': fundedAmountCents,
        'freelancerPayoutCents': freelancerPayoutCents,
        'deliveryDisputeDeadline':
            deliveryDisputeDeadline?.toIso8601String(),
        'payoutFinalized': payoutFinalized,
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
      lifecyclePhase:
          json['lifecyclePhase'] as String? ?? ProposalLifecycle.submitted,
      fundedAmountCents: (json['fundedAmountCents'] as num?)?.toInt(),
      freelancerPayoutCents: (json['freelancerPayoutCents'] as num?)?.toInt(),
      deliveryDisputeDeadline: DateTime.tryParse(
        '${json['deliveryDisputeDeadline'] ?? ''}',
      ),
      payoutFinalized: json['payoutFinalized'] as bool? ?? false,
    );
  }
}
