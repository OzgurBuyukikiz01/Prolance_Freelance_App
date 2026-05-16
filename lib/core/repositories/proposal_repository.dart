import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
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
    notifyListeners();
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
}
