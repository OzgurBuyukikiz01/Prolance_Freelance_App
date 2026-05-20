import 'dart:async';

import 'dart:convert';



import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:supabase_flutter/supabase_flutter.dart';



import '../config/supabase_config.dart';

import '../models/feed_notification_item.dart';

import '../models/job_model.dart';

import '../repositories/notification_repository.dart';

import '../repositories/job_remote_repository.dart';

import '../repositories/supabase_job_repository.dart';



/// Encapsulates all jobs-related state previously inside [AppState].

///

/// Handles: jobs list, favorites, add/post job, admin moderation via Realtime,

/// approval popup queue, and local + remote persistence.

class JobsProvider extends ChangeNotifier {

  JobsProvider();



  static const _kJobs = 'jobs_json';



  List<JobModel> _jobs = JobModel.dummyList();

  RealtimeChannel? _jobsRealtimeChannel;

  StreamSubscription<AuthState>? _jobsAuthSub;

  Timer? _jobsRealtimeDebounce;

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

    _subscribeJobsRealtime();

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



    final remoteJobs = await JobRemoteRepository.tryFetchAll();

    if (remoteJobs != null && remoteJobs.isNotEmpty) {

      _jobs = remoteJobs;

      await _persistJobs();

    }

  }



  bool _isSupabaseClientReady() {

    if (!SupabaseConfig.isEnabled) return false;

    try {

      Supabase.instance.client;

      return true;

    } catch (_) {

      return false;

    }

  }



  /// Inserts/updates/deletes on [jobs] (RLS: rows the user can SELECT).

  void _subscribeJobsRealtime() {

    if (!_isSupabaseClientReady()) return;

    final client = Supabase.instance.client;

    _jobsAuthSub ??= client.auth.onAuthStateChange.listen((_) {

      _attachJobsRealtimeChannel();

    });

    _attachJobsRealtimeChannel();

  }



  void _attachJobsRealtimeChannel() {

    _jobsRealtimeDebounce?.cancel();

    _jobsRealtimeDebounce = null;

    _jobsRealtimeChannel?.unsubscribe();

    _jobsRealtimeChannel = null;



    if (!SupabaseConfig.isEnabled) return;

    if (!_isSupabaseClientReady()) return;

    try {

      final client = Supabase.instance.client;

      final uid = client.auth.currentUser?.id;

      if (uid == null) return;



      _jobsRealtimeChannel = client

          .channel('public:jobs:$uid')

          .onPostgresChanges(

            event: PostgresChangeEvent.all,

            schema: 'public',

            table: 'jobs',

            callback: (_) => _debouncedReloadJobsFromRemote(),

          )

          .subscribe();

    } catch (e) {

      debugPrint('[JobsProvider] jobs realtime subscribe: $e');

    }

  }



  void _debouncedReloadJobsFromRemote() {

    _jobsRealtimeDebounce?.cancel();

    _jobsRealtimeDebounce =

        Timer(const Duration(milliseconds: 400), () async {

      await _pullRemoteJobsWithModerationDetection();

    });

  }



  /// Full job list from Supabase; detects pending_review → open for the job owner.

  Future<void> _pullRemoteJobsWithModerationDetection() async {

    if (!SupabaseConfig.isEnabled) return;

    try {

      final uid = Supabase.instance.client.auth.currentUser?.id;



      final remote = await SupabaseJobRepository.fetchAll();

      final prevById = {for (final j in _jobs) j.id: j};



      if (remote.isNotEmpty) {

        if (uid != null) {

          for (final j in remote) {

            final prev = prevById[j.id];

            if (prev != null &&

                prev.status == 'pending_review' &&

                j.status == 'open' &&

                j.clientId == uid) {

              _jobIdsHeldUntilApprovalDismiss.add(j.id);

              _approvalPopupQueue.add(

                PendingApprovalJob(jobId: j.id, title: j.title),

              );

            }

          }

        }

        _jobs = remote;

      } else {

        _jobs = [];

      }

      await _persistJobs();

      notifyListeners();

    } catch (e) {

      debugPrint('[JobsProvider] realtime jobs reload: $e');

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



  Future<void> addJob(

    JobModel job, {

    required String currentUserName,

    required String currentUserAvatar,

    NotificationRepository? notifications,

    required String Function(String en, String tr) t,

  }) async {

    final toInsert =
        job.isUserPosted ? job.copyWith(status: 'open') : job;

    final merged = toInsert.copyWith(

      clientName: currentUserName,

      clientAvatar: currentUserAvatar,

    );



    if (SupabaseConfig.isEnabled) {

      final inserted = await SupabaseJobRepository.insertAndMap(merged);

      if (inserted != null) {

        _jobs.insert(0, inserted);

        if (inserted.isUserPosted && inserted.status == 'open') {

          _notifyUserPostLive(inserted.title,

              notifications: notifications, t: t);

        }

      } else {

        _jobs.insert(0, merged);

        if (merged.isUserPosted && merged.status == 'open') {

          _notifyUserPostLive(merged.title,

              notifications: notifications, t: t);

        }

      }

    } else {

      _jobs.insert(0, merged);

      await JobRemoteRepository.tryCreate(merged);

      if (merged.isUserPosted && merged.status == 'open') {

        _notifyUserPostLive(merged.title,

            notifications: notifications, t: t);

      }

    }



    await _persistJobs();

    notifyListeners();

  }



  // ---------------------------------------------------------------------------

  // Internal helpers

  // ---------------------------------------------------------------------------



  void _notifyUserPostLive(

    String title, {

    NotificationRepository? notifications,

    required String Function(String en, String tr) t,

  }) {

    final titleText = t('Published', 'Yayınlandı');

    final body = t(

      'Your listing is now visible on Home.',

      'İlanınız ana sayfada görünüyor.',

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

    _jobsAuthSub?.cancel();

    _jobsAuthSub = null;

    _jobsRealtimeDebounce?.cancel();

    _jobsRealtimeDebounce = null;

    _jobsRealtimeChannel?.unsubscribe();

    _jobsRealtimeChannel = null;

    super.dispose();

  }

}



class PendingApprovalJob {

  PendingApprovalJob({required this.jobId, required this.title});



  final String jobId;

  final String title;

}

