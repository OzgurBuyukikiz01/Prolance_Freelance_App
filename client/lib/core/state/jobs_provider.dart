import 'dart:async';

import 'dart:convert';



import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:supabase_flutter/supabase_flutter.dart';



import '../config/supabase_config.dart';

import '../models/feed_notification_item.dart';

import '../models/job_model.dart';

import '../repositories/notification_repository.dart';


import '../repositories/supabase_job_repository.dart';



/// Encapsulates all jobs-related state previously inside [AppState].

///

/// Handles: jobs list, favorites, add/post job, admin moderation via Realtime,

/// approval popup queue, and local + remote persistence.

class JobsProvider extends ChangeNotifier {

  JobsProvider();



  static const _kJobs = 'jobs_json';



  List<JobModel> _jobs = JobModel.dummyList();

  RealtimeChannel? _ownJobsChannel;

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

              j.status == 'pending_review' ||

              j.status == 'rejected'))

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

    _subscribeToOwnJobModerationUpdates();

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

        // Supabase enabled but unreachable — show empty list (no demo fallback).

      }

      _jobs = [];

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



  }



  void _subscribeToOwnJobModerationUpdates() {

    _ownJobsChannel?.unsubscribe();

    _ownJobsChannel = null;



    if (!SupabaseConfig.isEnabled) return;



    final client = Supabase.instance.client;

    final uid = client.auth.currentUser?.id;

    if (uid == null) return;



    _ownJobsChannel = client

        .channel('own-jobs-moderation-$uid')

        .onPostgresChanges(

          event: PostgresChangeEvent.update,

          schema: 'public',

          table: 'jobs',

          filter: PostgresChangeFilter(

            type: PostgresChangeFilterType.eq,

            column: 'client_id',

            value: uid,

          ),

          callback: (payload) => unawaited(_onOwnJobUpdated(payload)),

        )

        .subscribe();

  }



  Future<void> _onOwnJobUpdated(PostgresChangePayload payload) async {

    final newRow = payload.newRecord;

    final oldRow = payload.oldRecord;

    if (newRow.isEmpty) return;



    final jobId = '${newRow['id']}';

    final newStatus = '${newRow['status']}';

    final oldStatus = oldRow.isNotEmpty ? '${oldRow['status']}' : null;

    final rejectionReason = newRow['rejection_reason'] as String?;



    final i = _jobs.indexWhere((j) => j.id == jobId);

    if (i < 0) return;



    final previous = _jobs[i];

    _jobs[i] = previous.copyWith(

      status: newStatus,

      rejectionReason: rejectionReason,

    );

    await _persistJobs();



    if (oldStatus == 'pending_review' && newStatus == 'open') {

      _jobIdsHeldUntilApprovalDismiss.add(jobId);

      _approvalPopupQueue.add(

        PendingApprovalJob(jobId: jobId, title: previous.title),

      );

    }



    notifyListeners();

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



  Future<void> addJob(

    JobModel job, {

    required String currentUserName,

    required String currentUserAvatar,

    NotificationRepository? notifications,

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

              notifications: notifications, t: t);

        }

      } else {

        _jobs.insert(0, merged);

        if (merged.isUserPosted && merged.status == 'pending_review') {

          _notifyJobPosted(merged.id, merged.title,

              notifications: notifications, t: t);

        }

      }

    } else {

      _jobs.insert(0, merged);

      if (merged.isUserPosted && merged.status == 'pending_review') {

        _notifyJobPosted(merged.id, merged.title,

            notifications: notifications, t: t);

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

    NotificationRepository? notifications,

    required String Function(String en, String tr) t,

  }) {

    final titleText = t('Post received', 'İlanınız iletilmiştir');

    final body = t(

      'Your listing is being reviewed. It will appear on Home once approved.',

      'İlanınız inceleniyor; onaylanınca ana sayfada görünecektir.',

    );

    if (notifications == null) return;

    unawaited(

      notifications.notifyCurrentUser(

        title: titleText,

        body: body,

        type: FeedNotificationType.job,

      ),

    );

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

    _ownJobsChannel?.unsubscribe();

    _ownJobsChannel = null;

    super.dispose();

  }

}



class PendingApprovalJob {

  PendingApprovalJob({required this.jobId, required this.title});



  final String jobId;

  final String title;

}

