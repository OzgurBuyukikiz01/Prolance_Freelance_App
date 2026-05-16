import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/feed_notification_item.dart';
import '../models/job_model.dart';
import '../repositories/job_remote_repository.dart';
import '../repositories/supabase_job_repository.dart';

/// Encapsulates all jobs-related state previously inside [AppState].
///
/// Handles: jobs list, favorites, add/post job, moderation timers, approval
/// popup queue, and local + remote persistence.
class JobsProvider extends ChangeNotifier {
  JobsProvider();

  static const _kJobs = 'jobs_json';

  List<JobModel> _jobs = JobModel.dummyList();
  final Map<String, Timer> _moderationTimers = {};
  final Set<String> _jobIdsHeldUntilApprovalDismiss = {};
  final List<PendingApprovalJob> _approvalPopupQueue = [];

  List<JobModel> get jobs => List.unmodifiable(_jobs);

  List<JobModel> get favoriteJobs =>
      _jobs.where((j) => j.isSaved).toList(growable: false);

  List<JobModel> activeJobsForUser(String userName) => _jobs
      .where((j) =>
          j.clientName == userName &&
          (j.status == 'open' ||
              j.status == 'in_progress' ||
              j.status == 'pending_review'))
      .toList(growable: false);

  PendingApprovalJob? get pendingApprovalPopupHead =>
      _approvalPopupQueue.isEmpty ? null : _approvalPopupQueue.first;

  bool shouldHideApprovedJobFromOwnerHome(String jobId) =>
      _jobIdsHeldUntilApprovalDismiss.contains(jobId);

  void dismissPendingApprovalPopup() {
    if (_approvalPopupQueue.isEmpty) return;
    final head = _approvalPopupQueue.removeAt(0);
    _jobIdsHeldUntilApprovalDismiss.remove(head.jobId);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Initialise / refresh
  // ---------------------------------------------------------------------------

  /// Call once on app boot (and again after login).
  Future<void> refresh() async {
    await _refreshJobsFromSources();
    _resumePendingModerationTimers();
    notifyListeners();
  }

  Future<void> _refreshJobsFromSources() async {
    if (SupabaseConfig.isEnabled) {
      try {
        final remote = await SupabaseJobRepository.fetchAll();
        if (remote.isNotEmpty) {
          _jobs = remote;
          await _persistJobs();
          return;
        }
      } catch (_) {
        // Local Supabase may be offline — fall back to bundled demo list.
      }
      _jobs = JobModel.dummyList();
      await _persistJobs();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final rawJobs = prefs.getString(_kJobs);
    if (rawJobs != null) {
      try {
        final decoded = jsonDecode(rawJobs) as List<dynamic>;
        _jobs = decoded
            .map((e) => JobModel.fromJson(e as Map<String, dynamic>))
            .toList(growable: true);
      } catch (_) {
        _jobs = JobModel.dummyList();
      }
    } else {
      _jobs = JobModel.dummyList();
    }

    final remoteJobs = await JobRemoteRepository.tryFetchAll();
    if (remoteJobs != null && remoteJobs.isNotEmpty) {
      _jobs = remoteJobs;
      await _persistJobs();
    }
  }

  void _resumePendingModerationTimers() {
    for (final j in _jobs) {
      if (j.status == 'pending_review' && j.isUserPosted) {
        _scheduleModerationPublish(
          j.id,
          j.title,
          onApproved: (_) {},
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Favorites
  // ---------------------------------------------------------------------------

  Future<void> toggleFavorite(String jobId, bool isSaved) async {
    final index = _jobs.indexWhere((j) => j.id == jobId);
    if (index < 0) return;
    _jobs[index] = _jobs[index].copyWith(isSaved: isSaved);
    if (SupabaseConfig.isEnabled) {
      try {
        await SupabaseJobRepository.setSaved(jobId, isSaved);
      } catch (_) {}
    }
    await _persistJobs();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Add job
  // ---------------------------------------------------------------------------

  /// [onNotify] receives [FeedNotificationItem]s that should be surfaced to the
  /// user (e.g. "post received", "post approved"). Caller decides how to show
  /// them — typically by forwarding to NotificationRepository or AppState.
  Future<void> addJob(
    JobModel job, {
    required String currentUserName,
    required String currentUserAvatar,
    required void Function(FeedNotificationItem) onNotify,
    required String Function(String en, String tr) t,
  }) async {
    final toInsert =
        job.isUserPosted ? job.copyWith(status: 'pending_review') : job;
    final merged = toInsert.copyWith(
      clientName: currentUserName,
      clientAvatar: currentUserAvatar,
    );

    if (SupabaseConfig.isEnabled) {
      final inserted = await SupabaseJobRepository.insertAndMap(merged);
      if (inserted != null) {
        _jobs.insert(0, inserted);
        if (inserted.isUserPosted && inserted.status == 'pending_review') {
          _notifyJobPosted(inserted.id, inserted.title,
              onNotify: onNotify, t: t);
          _scheduleModerationPublish(
            inserted.id,
            inserted.title,
            onApproved: (item) => onNotify(item),
          );
        }
      } else {
        _jobs.insert(0, merged);
        if (merged.isUserPosted && merged.status == 'pending_review') {
          _notifyJobPosted(merged.id, merged.title,
              onNotify: onNotify, t: t);
          _scheduleModerationPublish(
            merged.id,
            merged.title,
            onApproved: (item) => onNotify(item),
          );
        }
      }
    } else {
      _jobs.insert(0, merged);
      await JobRemoteRepository.tryCreate(merged);
      if (merged.isUserPosted && merged.status == 'pending_review') {
        _notifyJobPosted(merged.id, merged.title, onNotify: onNotify, t: t);
        _scheduleModerationPublish(
          merged.id,
          merged.title,
          onApproved: (item) => onNotify(item),
        );
      }
    }

    await _persistJobs();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  void _notifyJobPosted(
    String id,
    String title, {
    required void Function(FeedNotificationItem) onNotify,
    required String Function(String en, String tr) t,
  }) {
    onNotify(
      FeedNotificationItem(
        id: 'post_rcv_$id',
        title: t('Post received', 'İlanınız iletilmiştir'),
        description: t(
          'Your listing is being reviewed. It will appear on Home once approved.',
          'İlanınız inceleniyor; onaylanınca ana sayfada görünecektir.',
        ),
        createdAt: DateTime.now(),
        type: FeedNotificationType.job,
      ),
    );
  }

  void _scheduleModerationPublish(
    String jobId,
    String jobTitle, {
    required void Function(FeedNotificationItem) onApproved,
  }) {
    _moderationTimers[jobId]?.cancel();
    final secs = 10 + Random().nextInt(6);
    _moderationTimers[jobId] = Timer(Duration(seconds: secs), () async {
      _moderationTimers.remove(jobId);
      final i = _jobs.indexWhere((j) => j.id == jobId);
      if (i < 0) return;
      if (_jobs[i].status != 'pending_review') return;
      _jobs[i] = _jobs[i].copyWith(status: 'open');
      await _persistJobs();
      if (SupabaseConfig.isEnabled) {
        try {
          await Supabase.instance.client
              .from('jobs')
              .update({'status': 'open'}).eq('id', jobId);
        } catch (_) {}
      } else {
        await JobRemoteRepository.tryCreate(_jobs[i]);
      }
      _jobIdsHeldUntilApprovalDismiss.add(jobId);
      _approvalPopupQueue
          .add(PendingApprovalJob(jobId: jobId, title: jobTitle));
      onApproved(
        FeedNotificationItem(
          id: 'post_live_${jobId}_${DateTime.now().millisecondsSinceEpoch}',
          title: 'İlanınız onaylandı',
          description: '"$jobTitle" yayına alındı ve ana sayfada görünecek.',
          createdAt: DateTime.now(),
          type: FeedNotificationType.job,
        ),
      );
      notifyListeners();
    });
  }

  Future<void> _persistJobs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kJobs,
      jsonEncode(_jobs.map((j) => j.toJson()).toList(growable: false)),
    );
  }

  @override
  void dispose() {
    for (final t in _moderationTimers.values) {
      t.cancel();
    }
    _moderationTimers.clear();
    super.dispose();
  }
}

class PendingApprovalJob {
  PendingApprovalJob({required this.jobId, required this.title});

  final String jobId;
  final String title;
}
