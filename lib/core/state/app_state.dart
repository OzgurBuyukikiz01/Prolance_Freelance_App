import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/feed_notification_item.dart';
import '../models/job_model.dart';
import '../models/user_model.dart';
import '../repositories/job_remote_repository.dart';
import '../theme/theme_preference.dart';

class AppState extends ChangeNotifier {
  AppState();

  static const _kLoggedIn = 'logged_in';
  static const _kJobs = 'jobs_json';
  static const _kUser = 'user_json';
  static const _kDarkMode = 'dark_mode'; // legacy — migrated to [_kThemePreference]
  static const _kThemePreference = 'theme_preference';
  static const _kLanguage = 'language';
  static const _kPassword = 'password';

  bool _isReady = false;
  bool _isLoggedIn = false;
  ThemePreference _themePreference = ThemePreference.system;
  String _languageCode = 'en';
  String _currentPassword = 'admin';
  UserModel _currentUser = UserModel.dummy();
  List<JobModel> _jobs = JobModel.dummyList();

  final List<FeedNotificationItem> _feedNotifications = [];
  final Map<String, Timer> _moderationTimers = {};
  Timer? _proposalCelebrationTimer;
  bool _showProposalSentCelebration = false;

  /// User-posted jobs approved (`open`) but kept off Home until the approval popup is dismissed.
  final Set<String> _jobIdsHeldUntilApprovalDismiss = <String>{};

  /// FIFO queue for approval popups (one dialog at a time).
  final List<PendingApprovalPopup> _approvalPopupQueue = [];

  bool get isReady => _isReady;
  bool get isLoggedIn => _isLoggedIn;
  ThemePreference get themePreference => _themePreference;

  /// Resolved Flutter theme mode (light / dark / follow system).
  ThemeMode get themeMode => switch (_themePreference) {
        ThemePreference.light => ThemeMode.light,
        ThemePreference.dark => ThemeMode.dark,
        ThemePreference.system => ThemeMode.system,
      };

  /// Whether dark palette is forced on (not system).
  bool get darkMode => _themePreference == ThemePreference.dark;
  String get languageCode => _languageCode;
  UserModel get currentUser => _currentUser;
  List<JobModel> get jobs => List.unmodifiable(_jobs);
  List<FeedNotificationItem> get feedNotifications =>
      List.unmodifiable(_feedNotifications);

  bool get showProposalSentCelebration => _showProposalSentCelebration;

  /// Next approval popup to show (after moderation); null if queue empty.
  PendingApprovalPopup? get pendingApprovalPopupHead =>
      _approvalPopupQueue.isEmpty ? null : _approvalPopupQueue.first;

  bool shouldHideApprovedJobFromOwnerHome(String jobId) =>
      _jobIdsHeldUntilApprovalDismiss.contains(jobId);

  void dismissPendingApprovalPopup() {
    if (_approvalPopupQueue.isEmpty) return;
    final head = _approvalPopupQueue.removeAt(0);
    _jobIdsHeldUntilApprovalDismiss.remove(head.jobId);
    notifyListeners();
  }

  void _enqueueApprovalPopup(String jobId, String jobTitle) {
    _jobIdsHeldUntilApprovalDismiss.add(jobId);
    _approvalPopupQueue
        .add(PendingApprovalPopup(jobId: jobId, title: jobTitle));
  }

  List<JobModel> get favoriteJobs =>
      _jobs.where((job) => job.isSaved).toList(growable: false);
  List<JobModel> get activeMyJobs => _jobs
      .where((job) =>
          job.clientName == _currentUser.name &&
          (job.status == 'open' ||
              job.status == 'in_progress' ||
              job.status == 'pending_review'))
      .toList(growable: false);

  String t(String en, String tr) => _languageCode == 'tr' ? tr : en;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool(_kLoggedIn) ?? false;
    final storedPref = prefs.getString(_kThemePreference);
    if (storedPref != null) {
      _themePreference = ThemePreference.fromStored(storedPref);
    } else if (prefs.containsKey(_kDarkMode)) {
      final legacyDark = prefs.getBool(_kDarkMode) ?? false;
      _themePreference =
          legacyDark ? ThemePreference.dark : ThemePreference.light;
      await prefs.setString(_kThemePreference, _themePreference.name);
    } else {
      _themePreference = ThemePreference.system;
      await prefs.setString(_kThemePreference, _themePreference.name);
    }
    _languageCode = prefs.getString(_kLanguage) ?? 'en';
    _currentPassword = prefs.getString(_kPassword) ?? 'admin';

    final rawUser = prefs.getString(_kUser);
    if (rawUser != null) {
      _currentUser = _userFromJson(jsonDecode(rawUser) as Map<String, dynamic>);
    }

    final rawJobs = prefs.getString(_kJobs);
    if (rawJobs != null) {
      final decoded = jsonDecode(rawJobs) as List<dynamic>;
      _jobs = decoded
          .map((entry) => JobModel.fromJson(entry as Map<String, dynamic>))
          .toList(growable: true);
    }

    final remoteJobs = await JobRemoteRepository.tryFetchAll();
    if (remoteJobs != null && remoteJobs.isNotEmpty) {
      _jobs = remoteJobs;
      await _persistJobs();
    }

    _resumePendingModerationTimers();

    _isReady = true;
    notifyListeners();
  }

  void _resumePendingModerationTimers() {
    for (final j in _jobs) {
      if (j.status == 'pending_review' && j.isUserPosted) {
        _scheduleModerationPublish(j.id, j.title);
      }
    }
  }

  @override
  void dispose() {
    for (final t in _moderationTimers.values) {
      t.cancel();
    }
    _moderationTimers.clear();
    _proposalCelebrationTimer?.cancel();
    super.dispose();
  }

  void triggerProposalSentCelebration() {
    _proposalCelebrationTimer?.cancel();
    _showProposalSentCelebration = true;
    notifyListeners();
    _proposalCelebrationTimer = Timer(const Duration(seconds: 5), () {
      _showProposalSentCelebration = false;
      notifyListeners();
    });
  }

  void dismissProposalSentCelebration() {
    _proposalCelebrationTimer?.cancel();
    _showProposalSentCelebration = false;
    notifyListeners();
  }

  void addFeedNotification(FeedNotificationItem item) {
    _feedNotifications.insert(0, item);
    notifyListeners();
  }

  void markAllFeedNotificationsRead() {
    for (var i = 0; i < _feedNotifications.length; i++) {
      _feedNotifications[i] =
          _feedNotifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  void removeFeedNotification(String id) {
    _feedNotifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void _scheduleModerationPublish(String jobId, String jobTitle) {
    _moderationTimers[jobId]?.cancel();
    final secs = 10 + Random().nextInt(6);
    _moderationTimers[jobId] = Timer(Duration(seconds: secs), () async {
      _moderationTimers.remove(jobId);
      final i = _jobs.indexWhere((j) => j.id == jobId);
      if (i < 0) return;
      if (_jobs[i].status != 'pending_review') return;
      _jobs[i] = _jobs[i].copyWith(status: 'open');
      await _persistJobs();
      await JobRemoteRepository.tryCreate(_jobs[i]);
      addFeedNotification(
        FeedNotificationItem(
          id: 'post_live_${jobId}_${DateTime.now().millisecondsSinceEpoch}',
          title: t('Post approved', 'İlanınız onaylandı'),
          description: t(
            '"$jobTitle" is now live on Home.',
            '"$jobTitle" yayına alındı ve ana sayfada görünüyor.',
          ),
          createdAt: DateTime.now(),
          type: FeedNotificationType.job,
        ),
      );
      _enqueueApprovalPopup(jobId, jobTitle);
      notifyListeners();
    });
  }

  Future<void> setLanguage(String code) async {
    _languageCode = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLanguage, code);
    notifyListeners();
  }

  Future<void> setThemePreference(ThemePreference preference) async {
    _themePreference = preference;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemePreference, preference.name);
    notifyListeners();
  }

  /// Backwards compatibility for older call sites (maps to light vs dark only).
  Future<void> setDarkMode(bool enabled) async {
    await setThemePreference(
      enabled ? ThemePreference.dark : ThemePreference.light,
    );
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    final normalizedUser = username.trim().toLowerCase();
    final normalizedPass = password.trim();
    final isAdmin = normalizedUser == 'admin' &&
        normalizedPass.toLowerCase() == _currentPassword.toLowerCase();
    final isRegisteredUser = normalizedUser == _currentUser.email.toLowerCase() &&
        normalizedPass == _currentPassword;

    if (!isAdmin && !isRegisteredUser) {
      return false;
    }
    _isLoggedIn = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLoggedIn, true);
    notifyListeners();
    return true;
  }

  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
    required bool isFreelancer,
  }) async {
    _currentUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      avatarUrl: 'https://i.pravatar.cc/150?img=${DateTime.now().millisecond % 60}',
      title: isFreelancer ? 'New Freelancer' : 'Project Owner',
      bio: isFreelancer
          ? 'New freelancer profile. Add your portfolio and skills to start getting jobs.'
          : 'New client profile. Create your first project to start hiring.',
      hourlyRate: 0,
      website: '',
      rating: 0,
      completedJobs: 0,
      totalEarnings: 0,
      skills: const [],
      location: 'Not set',
      isFreelancer: isFreelancer,
      joinedDate: DateTime.now(),
    );
    _currentPassword = password;
    _isLoggedIn = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUser, jsonEncode(_userToJson(_currentUser)));
    await prefs.setString(_kPassword, _currentPassword);
    await prefs.setBool(_kLoggedIn, true);
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLoggedIn, false);
    notifyListeners();
  }

  Future<void> changePassword(String nextPassword) async {
    _currentPassword = nextPassword;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPassword, nextPassword);
  }

  Future<void> updateUser(UserModel user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUser, jsonEncode(_userToJson(user)));
    notifyListeners();
  }

  Future<void> toggleFavorite(String jobId, bool isSaved) async {
    final index = _jobs.indexWhere((j) => j.id == jobId);
    if (index < 0) return;
    _jobs[index] = _jobs[index].copyWith(isSaved: isSaved);
    await _persistJobs();
    notifyListeners();
  }

  Future<void> addJob(JobModel job) async {
    final toInsert =
        job.isUserPosted ? job.copyWith(status: 'pending_review') : job;
    _jobs.insert(0, toInsert);
    await _persistJobs();
    await JobRemoteRepository.tryCreate(toInsert);

    if (toInsert.isUserPosted && toInsert.status == 'pending_review') {
      addFeedNotification(
        FeedNotificationItem(
          id: 'post_rcv_${toInsert.id}',
          title: t('Post received', 'İlanınız iletilmiştir'),
          description: t(
            'Your listing is being reviewed. It will appear on Home once approved (usually within moments in this demo).',
            'İlanınız inceleniyor; onaylanınca ana sayfada görünecektir.',
          ),
          createdAt: DateTime.now(),
          type: FeedNotificationType.job,
        ),
      );
      _scheduleModerationPublish(toInsert.id, toInsert.title);
    }

    notifyListeners();
  }

  Future<void> _persistJobs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kJobs,
      jsonEncode(_jobs.map((j) => j.toJson()).toList(growable: false)),
    );
  }

  static Map<String, dynamic> _userToJson(UserModel user) => {
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'avatarUrl': user.avatarUrl,
        'title': user.title,
        'bio': user.bio,
        'hourlyRate': user.hourlyRate,
        'website': user.website,
        'rating': user.rating,
        'completedJobs': user.completedJobs,
        'totalEarnings': user.totalEarnings,
        'skills': user.skills,
        'location': user.location,
        'isFreelancer': user.isFreelancer,
        'joinedDate': user.joinedDate.toIso8601String(),
      };

  static UserModel _userFromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        avatarUrl: json['avatarUrl'] as String,
        title: json['title'] as String,
        bio: json['bio'] as String,
        hourlyRate: (json['hourlyRate'] as num?)?.toDouble() ?? 0,
        website: json['website'] as String? ?? '',
        rating: (json['rating'] as num).toDouble(),
        completedJobs: json['completedJobs'] as int,
        totalEarnings: json['totalEarnings'] as int,
        skills: (json['skills'] as List<dynamic>).map((e) => '$e').toList(),
        location: json['location'] as String,
        isFreelancer: json['isFreelancer'] as bool,
        joinedDate: DateTime.parse(json['joinedDate'] as String),
      );
}

/// Shown after moderation: job is `open` but hidden from owner's Home until dismissed.
class PendingApprovalPopup {
  PendingApprovalPopup({required this.jobId, required this.title});

  final String jobId;
  final String title;
}
