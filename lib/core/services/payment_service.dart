import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/escrow_transaction_model.dart';

/// Mock-safe escrow operations (DB + optional Edge Function).
class PaymentService {
  PaymentService._();

  static final PaymentService instance = PaymentService._();

  SupabaseClient? get _c {
    if (!SupabaseConfig.isEnabled) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Debug: JWT expiry from current session (requires initialized Supabase).
  DateTime? accessTokenExpiry() {
    final token = _c?.auth.currentSession?.accessToken;
    if (token == null) return null;
    try {
      return JwtDecoder.getExpirationDate(token);
    } catch (_) {
      return null;
    }
  }

  Future<List<EscrowTransactionModel>> listForJob(String jobId) async {
    final c = _c;
    if (c == null) return [];
    final rows = await c
        .from('escrow_transactions')
        .select()
        .eq('job_id', jobId)
        .order('created_at', ascending: false);
    return (rows as List<dynamic>)
        .map((e) => EscrowTransactionModel.fromRow(e as Map<String, dynamic>))
        .toList();
  }

  Future<EscrowTransactionModel?> createFunded({
    required String jobId,
    required int amountCents,
    String currency = 'TRY',
  }) async {
    final c = _c;
    final uid = c?.auth.currentUser?.id;
    if (c == null || uid == null) return null;
    final row = await c
        .from('escrow_transactions')
        .insert({
          'job_id': jobId,
          'employer_id': uid,
          'amount_cents': amountCents,
          'currency': currency,
          'status': EscrowStatus.funded.dbValue,
        })
        .select()
        .single();
    return EscrowTransactionModel.fromRow(
      Map<String, dynamic>.from(row as Map),
    );
  }

  Future<void> setFreelancerHeld({
    required String escrowId,
    required String freelancerId,
  }) async {
    final c = _c;
    if (c == null) return;
    await c.from('escrow_transactions').update({
      'freelancer_id': freelancerId,
      'status': EscrowStatus.held.dbValue,
    }).eq('id', escrowId);
  }

  Future<void> releaseToFreelancer(String escrowId) async {
    final c = _c;
    if (c == null) return;
    try {
      await c.functions.invoke(
        'escrow',
        body: {'op': 'release', 'escrowId': escrowId},
      );
    } catch (_) {
      await c.from('escrow_transactions').update({
        'status': EscrowStatus.released.dbValue,
      }).eq('id', escrowId);
    }
  }

  Future<void> openDispute({
    required String escrowId,
    required String reason,
  }) async {
    final c = _c;
    if (c == null) return;
    try {
      await c.functions.invoke(
        'escrow',
        body: {'op': 'dispute', 'escrowId': escrowId, 'reason': reason},
      );
    } catch (_) {
      await c.from('escrow_transactions').update({
        'status': EscrowStatus.disputed.dbValue,
        'dispute_reason': reason,
      }).eq('id', escrowId);
    }
  }

  Future<void> refundEmployer(String escrowId) async {
    final c = _c;
    if (c == null) return;
    await c.from('escrow_transactions').update({
      'status': EscrowStatus.refunded.dbValue,
    }).eq('id', escrowId);
  }
}
