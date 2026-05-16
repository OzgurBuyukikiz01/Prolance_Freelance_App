import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/api_config.dart';
import '../config/supabase_config.dart';
import '../models/submitted_proposal_model.dart';

class ProposalRepository extends ChangeNotifier {
  ProposalRepository();

  static const _kStoreKey = 'my_submitted_proposals_json';

  final List<SubmittedProposal> _myProposals = [];

  List<SubmittedProposal> get myProposals => List.unmodifiable(_myProposals);

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kStoreKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _myProposals
          ..clear()
          ..addAll(
            decoded.map(
              (e) => SubmittedProposal.fromJson(e as Map<String, dynamic>),
            ),
          );
      } catch (_) {
        _myProposals.clear();
      }
    }

    if (SupabaseConfig.isEnabled) {
      await _loadFromSupabase();
    }

    notifyListeners();
  }

  /// Fetches proposals submitted by the current user from Supabase and merges
  /// with the local SharedPrefs cache (Supabase is source of truth).
  Future<void> _loadFromSupabase() async {
    try {
      final client = Supabase.instance.client;
      final uid = client.auth.currentUser?.id;
      if (uid == null) return;

      final rows = await client
          .from('proposals')
          .select()
          .eq('freelancer_id', uid)
          .order('created_at', ascending: false);

      final remoteIds = <String>{};
      final remoteList = <SubmittedProposal>[];

      for (final row in rows) {
        final id = '${row['id']}';
        remoteIds.add(id);
        remoteList.add(SubmittedProposal(
          id: id,
          jobId: '${row['job_id']}',
          jobTitle: '${row['job_title'] ?? ''}',
          bid: (row['bid'] as num?)?.toDouble() ?? 0,
          deliveryYears: 0,
          deliveryMonths: 0,
          deliveryDays: (row['delivery_days'] as num?)?.toInt() ?? 0,
          coverLetter: '${row['cover_letter'] ?? ''}',
          attachmentNames: (row['attachments'] as List<dynamic>?)
                  ?.map((e) => '$e')
                  .toList() ??
              [],
          submittedAt:
              DateTime.tryParse('${row['created_at']}') ?? DateTime.now(),
          status: _parseStatus('${row['status']}'),
        ));
      }

      // Merge: keep local-only entries that haven't been synced yet, then
      // prepend all Supabase rows (Supabase wins for duplicates).
      final localOnly = _myProposals
          .where((p) => !remoteIds.contains(p.id))
          .toList();
      _myProposals
        ..clear()
        ..addAll(remoteList)
        ..addAll(localOnly);

      await _persist();
    } catch (e) {
      debugPrint('[ProposalRepository] Supabase load error: $e');
    }
  }

  static SubmittedProposalStatus _parseStatus(String s) {
    switch (s) {
      case 'accepted':
        return SubmittedProposalStatus.accepted;
      case 'rejected':
        return SubmittedProposalStatus.declined;
      case 'cancelled':
        return SubmittedProposalStatus.cancelled;
      default:
        return SubmittedProposalStatus.awaitingResponse;
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kStoreKey,
      jsonEncode(_myProposals.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> cancelProposal(String id) async {
    final i = _myProposals.indexWhere((p) => p.id == id);
    if (i < 0) return;
    if (_myProposals[i].status != SubmittedProposalStatus.awaitingResponse) {
      return;
    }
    _myProposals[i] =
        _myProposals[i].copyWith(status: SubmittedProposalStatus.cancelled);
    await _persist();
    notifyListeners();
  }

  Future<void> submitProposal({
    required String jobId,
    required String jobTitle,
    required double bid,
    required int deliveryYears,
    required int deliveryMonths,
    required int deliveryDays,
    required String coverLetter,
    required List<String> attachmentNames,
  }) async {
    final record = SubmittedProposal(
      id: 'prop_${DateTime.now().millisecondsSinceEpoch}',
      jobId: jobId,
      jobTitle: jobTitle,
      bid: bid,
      deliveryYears: deliveryYears,
      deliveryMonths: deliveryMonths,
      deliveryDays: deliveryDays,
      coverLetter: coverLetter,
      attachmentNames: List<String>.from(attachmentNames),
      submittedAt: DateTime.now(),
      status: SubmittedProposalStatus.awaitingResponse,
    );
    _myProposals.insert(0, record);
    await _persist();
    notifyListeners();

    if (SupabaseConfig.isEnabled) {
      try {
        final client = Supabase.instance.client;
        final uid = client.auth.currentUser?.id;
        if (uid != null) {
          try {
            final approxDays = deliveryYears * 365 +
                deliveryMonths * 30 +
                deliveryDays;
            await client.from('proposals').insert({
              'job_id': jobId,
              'freelancer_id': uid,
              'bid': bid,
              'delivery_days': approxDays > 0 ? approxDays : deliveryDays,
              'cover_letter': coverLetter,
              'attachments': attachmentNames,
            });
          } catch (_) {}
        }
      } catch (_) {}
    }

    if (!ApiConfig.isConfigured) return;
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/v1/jobs/$jobId/proposals');
      await http.post(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'bid': bid,
          'deliveryYears': deliveryYears,
          'deliveryMonths': deliveryMonths,
          'deliveryDays': deliveryDays,
          'deliveryDaysApproximate':
              deliveryYears * 365 + deliveryMonths * 30 + deliveryDays,
          'coverLetter': coverLetter,
          'attachments': attachmentNames,
        }),
      );
    } catch (_) {
      // Demo build continues offline.
    }
  }

  /// Proposals for a job (job owner view).
  Future<List<JobProposalRow>> fetchForJob(String jobId) async {
    if (!SupabaseConfig.isEnabled) return [];
    try {
      final client = Supabase.instance.client;
      final rows = await client
          .from('proposals')
          .select(
            'id, job_id, freelancer_id, bid, delivery_days, cover_letter, status, created_at',
          )
          .eq('job_id', jobId)
          .order('created_at', ascending: false);

      return (rows as List<dynamic>).map((row) {
        final map = row as Map<String, dynamic>;
        return JobProposalRow(
          id: '${map['id']}',
          jobId: '${map['job_id']}',
          freelancerId: '${map['freelancer_id']}',
          bid: (map['bid'] as num?)?.toDouble() ?? 0,
          deliveryDays: (map['delivery_days'] as num?)?.toInt() ?? 0,
          coverLetter: '${map['cover_letter'] ?? ''}',
          status: '${map['status'] ?? 'pending'}',
        );
      }).toList();
    } catch (e) {
      debugPrint('[ProposalRepository] fetchForJob: $e');
      return [];
    }
  }

  Future<bool> rejectProposal(String proposalId) async {
    if (!SupabaseConfig.isEnabled) return false;
    try {
      await Supabase.instance.client
          .from('proposals')
          .update({'status': 'rejected'})
          .eq('id', proposalId);
      return true;
    } catch (e) {
      debugPrint('[ProposalRepository] rejectProposal: $e');
      return false;
    }
  }

  Future<bool> acceptProposal({
    required String proposalId,
    required String jobId,
    required String freelancerId,
    required double bid,
  }) async {
    if (!SupabaseConfig.isEnabled) return false;
    try {
      final client = Supabase.instance.client;
      final uid = client.auth.currentUser?.id;
      if (uid == null) return false;

      await client
          .from('proposals')
          .update({'status': 'accepted'})
          .eq('id', proposalId);

      await client.from('escrow_transactions').insert({
        'job_id': jobId,
        'employer_id': uid,
        'freelancer_id': freelancerId,
        'amount_cents': (bid * 100).round(),
        'status': 'HELD',
      });
      return true;
    } catch (e) {
      debugPrint('[ProposalRepository] acceptProposal: $e');
      return false;
    }
  }
}

class JobProposalRow {
  const JobProposalRow({
    required this.id,
    required this.jobId,
    required this.freelancerId,
    required this.bid,
    required this.deliveryDays,
    required this.coverLetter,
    required this.status,
    this.freelancerName,
    this.freelancerAvatar,
  });

  final String id;
  final String jobId;
  final String freelancerId;
  final double bid;
  final int deliveryDays;
  final String coverLetter;
  final String status;
  final String? freelancerName;
  final String? freelancerAvatar;

  bool get isPending => status == 'pending';
}
