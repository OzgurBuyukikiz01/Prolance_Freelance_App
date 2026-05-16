/// Maps to Postgres enum `public.escrow_status`.
enum EscrowStatus {
  funded('FUNDED'),
  held('HELD'),
  released('RELEASED'),
  disputed('DISPUTED'),
  refunded('REFUNDED');

  const EscrowStatus(this.dbValue);
  final String dbValue;

  static EscrowStatus fromDb(String? v) {
    for (final e in EscrowStatus.values) {
      if (e.dbValue == v) return e;
    }
    return EscrowStatus.funded;
  }
}

class EscrowTransactionModel {
  const EscrowTransactionModel({
    required this.id,
    required this.jobId,
    required this.employerId,
    this.freelancerId,
    required this.amountCents,
    required this.currency,
    required this.status,
    this.disputeReason,
    required this.createdAt,
  });

  final String id;
  final String jobId;
  final String employerId;
  final String? freelancerId;
  final int amountCents;
  final String currency;
  final EscrowStatus status;
  final String? disputeReason;
  final DateTime createdAt;

  factory EscrowTransactionModel.fromRow(Map<String, dynamic> row) {
    return EscrowTransactionModel(
      id: '${row['id']}',
      jobId: '${row['job_id']}',
      employerId: '${row['employer_id']}',
      freelancerId: row['freelancer_id'] != null
          ? '${row['freelancer_id']}'
          : null,
      amountCents: (row['amount_cents'] as num).toInt(),
      currency: row['currency'] as String? ?? 'TRY',
      status: EscrowStatus.fromDb(row['status'] as String?),
      disputeReason: row['dispute_reason'] as String?,
      createdAt: DateTime.parse('${row['created_at']}'),
    );
  }
}
