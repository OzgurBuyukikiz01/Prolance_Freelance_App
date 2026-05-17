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
  static const _kHiddenIdsKey = 'my_proposals_swiped_hidden_ids_json';

  final List<SubmittedProposal> _myProposals = [];
  final Set<String> _swipeHiddenIds = {};
  final List<ClientIncomingProposal> _clientIncoming = [];

  /// Last `rpc_accept_proposal` error code (e.g. `insufficient_demo_balance`).
  String? lastAcceptErrorCode;

  List<SubmittedProposal> get myProposals => List.unmodifiable(_myProposals);

  List<ClientIncomingProposal> get clientIncoming =>
      List.unmodifiable(_clientIncoming);

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final hiddenRaw = prefs.getString(_kHiddenIdsKey);
    _swipeHiddenIds.clear();
    if (hiddenRaw != null && hiddenRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(hiddenRaw) as List<dynamic>;
        _swipeHiddenIds.addAll(decoded.map((e) => '$e'));
      } catch (_) {}
    }

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
      await finalizePayoutsIfDue();
      await _loadIncomingForClient();
    }

    notifyListeners();
  }

  Future<void> finalizePayoutsIfDue() async {
    if (!SupabaseConfig.isEnabled) return;
    try {
      await Supabase.instance.client.rpc('rpc_finalize_proposal_payouts');
    } catch (e) {
      debugPrint('[ProposalRepository] finalizePayoutsIfDue: $e');
    }
  }

  /// Pull-to-refresh on My Proposals (picks up accepted / rejected from server).
  Future<void> reloadFromRemote() async {
    if (!SupabaseConfig.isEnabled) return;
    await finalizePayoutsIfDue();
    await _loadFromSupabase();
    await _loadIncomingForClient();
    notifyListeners();
  }

  /// Swipe-remove from My Proposals for [cancelled] or [declined] rows only.
  Future<void> dismissFromMyList(String proposalId) async {
    final i = _myProposals.indexWhere((p) => p.id == proposalId);
    if (i < 0) return;
    final s = _myProposals[i].status;
    if (s != SubmittedProposalStatus.cancelled &&
        s != SubmittedProposalStatus.declined) {
      return;
    }
    _swipeHiddenIds.add(proposalId);
    _myProposals.removeAt(i);
    await _persist();
    notifyListeners();
  }

  bool canSwipeDismiss(SubmittedProposalStatus s) =>
      s == SubmittedProposalStatus.cancelled ||
      s == SubmittedProposalStatus.declined;

  /// Fetches proposals submitted by the current user from Supabase and merges
  /// with the local SharedPrefs cache (Supabase is source of truth).
  Future<void> _loadFromSupabase() async {
    try {
      final client = Supabase.instance.client;
      final uid = client.auth.currentUser?.id;
      if (uid == null) return;

      final rows = await client
          .from('proposals')
          .select(
            'id, job_id, bid, delivery_days, cover_letter, attachments, status, created_at, lifecycle_phase, funded_amount_cents, freelancer_payout_cents, delivery_dispute_deadline, payout_finalized',
          )
          .eq('freelancer_id', uid)
          .order('created_at', ascending: false);

      final list = rows as List<dynamic>;
      final jobIds = <String>{};
      for (final row in list) {
        jobIds.add('${(row as Map)['job_id']}');
      }
      final titles = await _fetchJobTitles(client, jobIds);

      final remoteIds = <String>{};
      final remoteList = <SubmittedProposal>[];

      for (final row in list) {
        final map = row as Map<String, dynamic>;
        final id = '${map['id']}';
        if (_swipeHiddenIds.contains(id)) continue;
        remoteIds.add(id);
        final jid = '${map['job_id']}';
        remoteList.add(SubmittedProposal(
          id: id,
          jobId: jid,
          jobTitle: titles[jid] ?? '',
          bid: (map['bid'] as num?)?.toDouble() ?? 0,
          deliveryYears: 0,
          deliveryMonths: 0,
          deliveryDays: (map['delivery_days'] as num?)?.toInt() ?? 0,
          coverLetter: '${map['cover_letter'] ?? ''}',
          attachmentNames: (map['attachments'] as List<dynamic>?)
                  ?.map((e) => '$e')
                  .toList() ??
              [],
          submittedAt:
              DateTime.tryParse('${map['created_at']}') ?? DateTime.now(),
          status: _parseStatus('${map['status']}'),
          lifecyclePhase:
              '${map['lifecycle_phase'] ?? ProposalLifecycle.submitted}',
          fundedAmountCents: (map['funded_amount_cents'] as num?)?.toInt(),
          freelancerPayoutCents:
              (map['freelancer_payout_cents'] as num?)?.toInt(),
          deliveryDisputeDeadline: DateTime.tryParse(
            '${map['delivery_dispute_deadline'] ?? ''}',
          ),
          payoutFinalized: map['payout_finalized'] == true,
        ));
      }

      // Merge: keep local-only entries that haven't been synced yet, then
      // prepend all Supabase rows (Supabase wins for duplicates).
      final localOnly = _myProposals
          .where(
            (p) =>
                !remoteIds.contains(p.id) && !_swipeHiddenIds.contains(p.id),
          )
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

  Future<void> _loadIncomingForClient() async {
    _clientIncoming.clear();
    if (!SupabaseConfig.isEnabled) return;
    try {
      final client = Supabase.instance.client;
      final uid = client.auth.currentUser?.id;
      if (uid == null) return;

      final jobRows =
          await client.from('jobs').select('id').eq('client_id', uid);
      final jobList = jobRows as List<dynamic>;
      final jobIds = jobList.map((e) => '${(e as Map)['id']}').toList();
      if (jobIds.isEmpty) return;

      final propRows = await client
          .from('proposals')
          .select(
            'id, job_id, freelancer_id, bid, delivery_days, cover_letter, status, created_at, lifecycle_phase, funded_amount_cents, freelancer_payout_cents, delivery_dispute_deadline, payout_finalized',
          )
          .inFilter('job_id', jobIds)
          .order('created_at', ascending: false);

      final proposals = propRows as List<dynamic>;
      final flIds = <String>{};
      final jids = <String>{};
      for (final r in proposals) {
        final m = r as Map<String, dynamic>;
        flIds.add('${m['freelancer_id']}');
        jids.add('${m['job_id']}');
      }

      final names = <String, String>{};
      if (flIds.isNotEmpty) {
        final prof =
            await client.from('profiles').select('id,full_name').inFilter(
                  'id',
                  flIds.toList(),
                );
        for (final p in prof as List<dynamic>) {
          final m = p as Map<String, dynamic>;
          names['${m['id']}'] = '${m['full_name'] ?? ''}';
        }
      }

      final titles = await _fetchJobTitles(client, jids);

      for (final r in proposals) {
        final m = r as Map<String, dynamic>;
        final jid = '${m['job_id']}';
        final fid = '${m['freelancer_id']}';
        _clientIncoming.add(
          ClientIncomingProposal(
            proposalId: '${m['id']}',
            jobId: jid,
            jobTitle: titles[jid] ?? '',
            freelancerId: fid,
            freelancerName: names[fid] ?? '',
            bid: (m['bid'] as num?)?.toDouble() ?? 0,
            deliveryDays: (m['delivery_days'] as num?)?.toInt() ?? 0,
            coverLetter: '${m['cover_letter'] ?? ''}',
            status: '${m['status']}',
            lifecyclePhase:
                '${m['lifecycle_phase'] ?? ProposalLifecycle.submitted}',
            fundedAmountCents: (m['funded_amount_cents'] as num?)?.toInt(),
            freelancerPayoutCents:
                (m['freelancer_payout_cents'] as num?)?.toInt(),
            deliveryDisputeDeadline: DateTime.tryParse(
              '${m['delivery_dispute_deadline'] ?? ''}',
            ),
            payoutFinalized: m['payout_finalized'] == true,
            createdAt:
                DateTime.tryParse('${m['created_at']}') ?? DateTime.now(),
          ),
        );
      }
    } catch (e) {
      debugPrint('[ProposalRepository] _loadIncomingForClient: $e');
    }
  }

  static Future<Map<String, String>> _fetchJobTitles(
    SupabaseClient client,
    Set<String> jobIds,
  ) async {
    if (jobIds.isEmpty) return {};
    final rows = await client
        .from('jobs')
        .select('id,title')
        .inFilter('id', jobIds.toList());
    final out = <String, String>{};
    for (final r in rows as List<dynamic>) {
      final m = r as Map<String, dynamic>;
      out['${m['id']}'] = '${m['title'] ?? ''}';
    }
    return out;
  }

  static Map<String, dynamic>? _asJsonMap(dynamic raw) {
    if (raw == null) return null;
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
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
    await prefs.setString(
      _kHiddenIdsKey,
      jsonEncode(_swipeHiddenIds.toList()),
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

  /// Returns Supabase proposal id when stored remotely; otherwise local id.
  Future<String?> submitProposal({
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

    String? serverProposalId;

    if (SupabaseConfig.isEnabled) {
      try {
        final client = Supabase.instance.client;
        final uid = client.auth.currentUser?.id;
        if (uid != null) {
          try {
            final approxDays = deliveryYears * 365 +
                deliveryMonths * 30 +
                deliveryDays;
            final inserted = await client.from('proposals').insert({
              'job_id': jobId,
              'freelancer_id': uid,
              'bid': bid,
              'delivery_days': approxDays > 0 ? approxDays : deliveryDays,
              'cover_letter': coverLetter,
              'attachments': attachmentNames,
            }).select('id').single();
            serverProposalId = '${inserted['id']}';
            final i = _myProposals.indexWhere((p) => p.id == record.id);
            if (i >= 0) {
              _myProposals[i] = _myProposals[i].copyWith(id: serverProposalId);
              await _persist();
              notifyListeners();
            }
          } catch (e) {
            debugPrint('[ProposalRepository] supabase insert: $e');
          }
        }
      } catch (e) {
        debugPrint('[ProposalRepository] submitProposal supabase: $e');
      }
    }

    if (!ApiConfig.isConfigured) {
      return serverProposalId ?? record.id;
    }
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
    return serverProposalId ?? record.id;
  }

  /// Proposals for a job (job owner view).
  Future<List<JobProposalRow>> fetchForJob(String jobId) async {
    if (!SupabaseConfig.isEnabled) return [];
    try {
      final client = Supabase.instance.client;
      final rows = await client
          .from('proposals')
          .select(
            'id, job_id, freelancer_id, bid, delivery_days, cover_letter, status, created_at, lifecycle_phase',
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
          lifecyclePhase:
              '${map['lifecycle_phase'] ?? ProposalLifecycle.submitted}',
        );
      }).toList();
    } catch (e) {
      debugPrint('[ProposalRepository] fetchForJob: $e');
      return [];
    }
  }

  Future<List<ProposalDeliveryRow>> fetchDeliveries(String proposalId) async {
    if (!SupabaseConfig.isEnabled) return [];
    try {
      final rows = await Supabase.instance.client
          .from('proposal_deliveries')
          .select('id,file_name,storage_path,created_at')
          .eq('proposal_id', proposalId)
          .order('created_at');
      return (rows as List<dynamic>).map((r) {
        final m = r as Map<String, dynamic>;
        return ProposalDeliveryRow(
          id: '${m['id']}',
          fileName: '${m['file_name']}',
          storagePath: '${m['storage_path']}',
          createdAt:
              DateTime.tryParse('${m['created_at']}') ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      debugPrint('[ProposalRepository] fetchDeliveries: $e');
      return [];
    }
  }

  /// Upload to private [deliverables] bucket then [rpc_register_proposal_delivery].
  Future<Map<String, dynamic>> uploadDeliveryAndRegister({
    required String proposalId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    if (!SupabaseConfig.isEnabled) {
      return {'ok': false, 'err': 'supabase_disabled'};
    }
    try {
      final client = Supabase.instance.client;
      final safe =
          fileName.replaceAll(RegExp(r'[^\w.\-]+'), '_').replaceAll('..', '.');
      final path =
          '$proposalId/${DateTime.now().millisecondsSinceEpoch}_$safe';
      await client.storage.from('deliverables').uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(
              upsert: false,
              contentType: 'application/octet-stream',
            ),
          );
      final raw = await client.rpc(
        'rpc_register_proposal_delivery',
        params: {
          'p_proposal_id': proposalId,
          'p_file_name': fileName,
          'p_storage_path': path,
        },
      );
      final m = _asJsonMap(raw) ?? {};
      if (m['ok'] != true) {
        try {
          await client.storage.from('deliverables').remove([path]);
        } catch (_) {}
      }
      return m;
    } catch (e) {
      debugPrint('[ProposalRepository] uploadDeliveryAndRegister: $e');
      return {'ok': false, 'err': 'upload_failed'};
    }
  }

  Future<Map<String, dynamic>> confirmFreelancerDeliverySubmission(
    String proposalId,
  ) async {
    if (!SupabaseConfig.isEnabled) return {'ok': false};
    try {
      final raw = await Supabase.instance.client.rpc(
        'rpc_freelancer_confirm_delivery_submission',
        params: {'p_proposal_id': proposalId},
      );
      return _asJsonMap(raw) ?? {'ok': false};
    } catch (e) {
      debugPrint('[ProposalRepository] confirmFreelancerDeliverySubmission: $e');
      return {'ok': false};
    }
  }

  /// Signed GET URL for a path in the private [deliverables] bucket.
  Future<String?> signedDeliverableDownloadUrl(
    String storagePath, {
    int expiresInSeconds = 3600,
  }) async {
    if (!SupabaseConfig.isEnabled) return null;
    try {
      return await Supabase.instance.client.storage
          .from('deliverables')
          .createSignedUrl(storagePath, expiresInSeconds);
    } catch (e) {
      debugPrint('[ProposalRepository] signedDeliverableDownloadUrl: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> clientReviewDelivery({
    required String proposalId,
    required bool accept,
  }) async {
    if (!SupabaseConfig.isEnabled) return {'ok': false};
    try {
      final raw = await Supabase.instance.client.rpc(
        'rpc_client_review_delivery',
        params: {
          'p_proposal_id': proposalId,
          'p_accept': accept,
        },
      );
      return _asJsonMap(raw) ?? {'ok': false};
    } catch (e) {
      debugPrint('[ProposalRepository] clientReviewDelivery: $e');
      return {'ok': false};
    }
  }

  Future<Map<String, dynamic>> disputeDelivery({
    required String proposalId,
    required String note,
  }) async {
    if (!SupabaseConfig.isEnabled) return {'ok': false};
    try {
      final raw = await Supabase.instance.client.rpc(
        'rpc_dispute_delivery_timeline',
        params: {
          'p_proposal_id': proposalId,
          'p_note': note,
        },
      );
      return _asJsonMap(raw) ?? {'ok': false};
    } catch (e) {
      debugPrint('[ProposalRepository] disputeDelivery: $e');
      return {'ok': false};
    }
  }

  Future<bool> rejectProposal(String proposalId) async {
    if (!SupabaseConfig.isEnabled) return false;
    try {
      final row = await Supabase.instance.client
          .from('proposals')
          .update({'status': 'rejected'})
          .eq('id', proposalId)
          .eq('status', 'pending')
          .select('id')
          .maybeSingle();
      return row != null;
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
    if (proposalId.isEmpty || jobId.isEmpty || freelancerId.isEmpty) {
      return false;
    }
    if (bid < 0) return false;
    lastAcceptErrorCode = null;
    if (!SupabaseConfig.isEnabled) return false;
    try {
      final raw = await Supabase.instance.client.rpc(
        'rpc_accept_proposal',
        params: {'p_proposal_id': proposalId},
      );
      final m = _asJsonMap(raw);
      if (m != null && m['ok'] == true) return true;
      if (m != null) lastAcceptErrorCode = m['err'] as String?;
      return false;
    } on PostgrestException catch (e) {
      debugPrint(
        '[ProposalRepository] acceptProposal Postgrest: ${e.message} ${e.details}',
      );
      return false;
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
    this.lifecyclePhase = ProposalLifecycle.submitted,
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
  final String lifecyclePhase;
  final String? freelancerName;
  final String? freelancerAvatar;

  bool get isPending => status == 'pending';
}

class ProposalDeliveryRow {
  const ProposalDeliveryRow({
    required this.id,
    required this.fileName,
    required this.storagePath,
    required this.createdAt,
  });

  final String id;
  final String fileName;
  final String storagePath;
  final DateTime createdAt;
}

class ClientIncomingProposal {
  const ClientIncomingProposal({
    required this.proposalId,
    required this.jobId,
    required this.jobTitle,
    required this.freelancerId,
    required this.freelancerName,
    required this.bid,
    required this.deliveryDays,
    required this.coverLetter,
    required this.status,
    required this.lifecyclePhase,
    this.fundedAmountCents,
    this.freelancerPayoutCents,
    this.deliveryDisputeDeadline,
    required this.payoutFinalized,
    required this.createdAt,
  });

  final String proposalId;
  final String jobId;
  final String jobTitle;
  final String freelancerId;
  final String freelancerName;
  final double bid;
  final int deliveryDays;
  final String coverLetter;
  final String status;
  final String lifecyclePhase;
  final int? fundedAmountCents;
  final int? freelancerPayoutCents;
  final DateTime? deliveryDisputeDeadline;
  final bool payoutFinalized;
  final DateTime createdAt;

  String get workflowLabel {
    if (status == 'rejected') return 'Declined';
    if (status == 'pending') return 'Waiting';
    if (status != 'accepted') return status;
    switch (lifecyclePhase) {
      case ProposalLifecycle.escrowFunded:
        return 'Accepted · in progress';
      case ProposalLifecycle.awaitingClientReview:
      case ProposalLifecycle.delivered:
        return 'Files · download & review';
      case ProposalLifecycle.payoutPending:
        return 'Payout window (24h)';
      case ProposalLifecycle.closed:
        return 'Completed';
      case ProposalLifecycle.disputed:
        return 'Disputed';
      default:
        return 'Accepted';
    }
  }
}
