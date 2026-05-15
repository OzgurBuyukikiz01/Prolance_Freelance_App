import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/job_model.dart';
import '../models/user_model.dart';

class AppState extends ChangeNotifier {
  AppState();

  static const _kLoggedIn = 'logged_in';
  static const _kJobs = 'jobs_json';
  static const _kUser = 'user_json';
  static const _kDarkMode = 'dark_mode';
  static const _kLanguage = 'language';
  static const _kPassword = 'password';

  bool _isReady = false;
  bool _isLoggedIn = false;
  bool _darkMode = false;
  String _languageCode = 'en';
  String _currentPassword = 'admin';
  UserModel _currentUser = UserModel.dummy();
  List<JobModel> _jobs = JobModel.dummyList();

  bool get isReady => _isReady;
  bool get isLoggedIn => _isLoggedIn;
  bool get darkMode => _darkMode;
  String get languageCode => _languageCode;
  UserModel get currentUser => _currentUser;
  List<JobModel> get jobs => List.unmodifiable(_jobs);
  List<JobModel> get favoriteJobs =>
      _jobs.where((job) => job.isSaved).toList(growable: false);
  List<JobModel> get activeMyJobs => _jobs
      .where((job) =>
          job.clientName == _currentUser.name &&
          (job.status == 'open' || job.status == 'in_progress'))
      .toList(growable: false);

  String t(String en, String tr) => _languageCode == 'tr' ? tr : en;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool(_kLoggedIn) ?? false;
    _darkMode = prefs.getBool(_kDarkMode) ?? false;
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
          .map((entry) => _jobFromJson(entry as Map<String, dynamic>))
          .toList(growable: true);
    }

    _isReady = true;
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    _languageCode = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLanguage, code);
    notifyListeners();
  }

  Future<void> setDarkMode(bool enabled) async {
    _darkMode = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDarkMode, enabled);
    notifyListeners();
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
    _jobs.insert(0, job);
    await _persistJobs();
    notifyListeners();
  }

  Future<void> _persistJobs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kJobs,
      jsonEncode(_jobs.map(_jobToJson).toList(growable: false)),
    );
  }

  static Map<String, dynamic> _jobToJson(JobModel job) => {
        'id': job.id,
        'title': job.title,
        'description': job.description,
        'clientName': job.clientName,
        'clientAvatar': job.clientAvatar,
        'budgetMin': job.budgetMin,
        'budgetMax': job.budgetMax,
        'budgetType': job.budgetType,
        'category': job.category,
        'skills': job.skills,
        'experienceLevel': job.experienceLevel,
        'postedDate': job.postedDate.toIso8601String(),
        'proposalCount': job.proposalCount,
        'duration': job.duration,
        'isSaved': job.isSaved,
        'status': job.status,
      };

  static JobModel _jobFromJson(Map<String, dynamic> json) => JobModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        clientName: json['clientName'] as String,
        clientAvatar: json['clientAvatar'] as String,
        budgetMin: (json['budgetMin'] as num).toDouble(),
        budgetMax: (json['budgetMax'] as num).toDouble(),
        budgetType: json['budgetType'] as String,
        category: json['category'] as String,
        skills: (json['skills'] as List<dynamic>).map((e) => '$e').toList(),
        experienceLevel: json['experienceLevel'] as String,
        postedDate: DateTime.parse(json['postedDate'] as String),
        proposalCount: json['proposalCount'] as int,
        duration: json['duration'] as String,
        isSaved: json['isSaved'] as bool,
        status: json['status'] as String,
      );

  static Map<String, dynamic> _userToJson(UserModel user) => {
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'avatarUrl': user.avatarUrl,
        'title': user.title,
        'bio': user.bio,
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
        rating: (json['rating'] as num).toDouble(),
        completedJobs: json['completedJobs'] as int,
        totalEarnings: json['totalEarnings'] as int,
        skills: (json['skills'] as List<dynamic>).map((e) => '$e').toList(),
        location: json['location'] as String,
        isFreelancer: json['isFreelancer'] as bool,
        joinedDate: DateTime.parse(json['joinedDate'] as String),
      );
}
