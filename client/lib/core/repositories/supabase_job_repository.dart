import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/job_model.dart';

/// Jobs backed by Supabase `public.jobs` + `job_saves`.
class SupabaseJobRepository {
  SupabaseJobRepository._();

  static SupabaseClient? get _c {
    if (!SupabaseConfig.isEnabled) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  static Future<List<String>> _savedJobIds(String? profileId) async {
    final c = _c;
    if (c == null || profileId == null) return [];
    final rows = await c
        .from('job_saves')
        .select('job_id')
        .eq('profile_id', profileId);
    return (rows as List<dynamic>)
        .map((e) => '${(e as Map<String, dynamic>)['job_id']}')
        .toList();
  }

  static JobModel _rowToJob(Map<String, dynamic> row, Set<String> savedIds) {
    final id = '${row['id']}';
    final skillsRaw = row['skills'];
    final skills = skillsRaw is List
        ? skillsRaw.map((e) => '$e').toList()
        : <String>[];

    return JobModel(
      id: id,
      title: row['title'] as String,
      description: row['description'] as String,
      clientName: row['client_name'] as String,
      clientAvatar: row['client_avatar'] as String,
      budgetMin: (row['budget_min'] as num).toDouble(),
      budgetMax: (row['budget_max'] as num).toDouble(),
      budgetType: row['budget_type'] as String,
      category: row['category'] as String,
      skills: skills,
      experienceLevel: row['experience_level'] as String,
      postedDate: DateTime.parse('${row['posted_date']}'),
      proposalCount: (row['proposal_count'] as num?)?.toInt() ?? 0,
      duration: row['duration'] as String,
      isSaved: savedIds.contains(id),
      status: row['status'] as String,
      rejectionReason: row['rejection_reason'] as String?,
      isUserPosted: row['is_user_posted'] as bool? ?? false,
      listingKind: row['listing_kind'] as String? ?? JobListingKinds.jobOffer,
    );
  }

  static Map<String, dynamic> _jobToInsert(JobModel job, String clientId) {
    return {
      'client_id': clientId,
      'title': job.title,
      'description': job.description,
      'client_name': job.clientName,
      'client_avatar': job.clientAvatar,
      'budget_min': job.budgetMin,
      'budget_max': job.budgetMax,
      'budget_type': job.budgetType,
      'category': job.category,
      'skills': job.skills,
      'experience_level': job.experienceLevel,
      'duration': job.duration,
      'proposal_count': job.proposalCount,
      'is_user_posted': job.isUserPosted,
      'listing_kind': job.listingKind,
      'status': job.status,
    };
  }

  static Future<List<JobModel>> fetchAll() async {
    final c = _c;
    if (c == null) return [];
    final uid = c.auth.currentUser?.id;
    final saved = (await _savedJobIds(uid)).toSet();

    final rows = await c
        .from('jobs')
        .select()
        .order('posted_date', ascending: false);

    return (rows as List<dynamic>)
        .map((e) => _rowToJob(e as Map<String, dynamic>, saved))
        .toList();
  }

  /// Inserts [job] and returns the row mapped to [JobModel] (new server id).
  static Future<JobModel?> insertAndMap(JobModel job) async {
    final c = _c;
    final uid = c?.auth.currentUser?.id;
    if (c == null || uid == null) return null;
    final row =
        await c.from('jobs').insert(_jobToInsert(job, uid)).select().single();
    final saved = await _savedJobIds(uid);
    return _rowToJob(Map<String, dynamic>.from(row as Map), saved.toSet());
  }

  static Future<void> setSaved(String jobId, bool saved) async {
    final c = _c;
    final uid = c?.auth.currentUser?.id;
    if (c == null || uid == null) return;
    if (saved) {
      await c.from('job_saves').upsert({
        'profile_id': uid,
        'job_id': jobId,
      });
    } else {
      await c.from('job_saves').delete().match({
        'profile_id': uid,
        'job_id': jobId,
      });
    }
  }
}
