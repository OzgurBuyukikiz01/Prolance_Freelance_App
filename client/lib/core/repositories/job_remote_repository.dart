import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/job_model.dart';

/// Remote jobs API — maps JSON from `GET /v1/jobs` into [JobModel].
class JobRemoteRepository {
  JobRemoteRepository._();

  static Future<List<JobModel>?> tryFetchAll() async {
    if (!ApiConfig.isConfigured) return null;
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/v1/jobs');
      final res = await http.get(uri);
      if (res.statusCode != 200) return null;
      final list = jsonDecode(res.body) as List<dynamic>;
      return list
          .map((e) => JobModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  static Future<void> tryCreate(JobModel job) async {
    if (!ApiConfig.isConfigured) return;
    try {
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/v1/jobs'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(job.toJson()),
      );
    } catch (_) {
      // Offline demo continues with local persistence only.
    }
  }
}
