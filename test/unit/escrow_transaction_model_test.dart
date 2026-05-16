import 'package:flutter_test/flutter_test.dart';
import 'package:prolance_app/core/models/escrow_transaction_model.dart';

void main() {
  test('EscrowStatus.fromDb maps enums', () {
    expect(EscrowStatus.fromDb('HELD'), EscrowStatus.held);
    expect(EscrowStatus.fromDb('RELEASED'), EscrowStatus.released);
    expect(EscrowStatus.fromDb(null), EscrowStatus.funded);
  });

  test('EscrowTransactionModel.fromRow parses row', () {
    final m = EscrowTransactionModel.fromRow({
      'id': 'e1',
      'job_id': 'j1',
      'employer_id': 'u1',
      'freelancer_id': null,
      'amount_cents': 5000,
      'currency': 'TRY',
      'status': 'FUNDED',
      'dispute_reason': null,
      'created_at': '2025-01-01T00:00:00.000Z',
    });
    expect(m.amountCents, 5000);
    expect(m.status, EscrowStatus.funded);
  });
}
