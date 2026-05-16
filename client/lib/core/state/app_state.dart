import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../theme/theme_preference.dart';
import 'jobs_provider.dart';

/// Slimmed-down AppState: owns auth, user, theme and proposal-celebration UI.
///
/// Jobs / favorites / moderation now live in [JobsProvider].
class AppState extends ChangeNotifier {
  AppState();

  static const _kDarkMode = 'dark_mode';
  static const _kThemePreference = 'theme_preference';
  static const _kLanguage = 'language';

  bool _isReady = false;
  bool _isLoggedIn = false;
  ThemePreference _themePreference = ThemePreference.system;
  String _languageCode = 'en';
  UserModel _currentUser = UserModel.dummy();

  Timer? _proposalCelebrationTimer;
  bool _showProposalSentCelebration = false;

  StreamSubscription<AuthState>? _authSubscription;

  ColorScheme? _lightDynamic;
  ColorScheme? _darkDynamic;

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  bool get isReady => _isReady;
  bool get isLoggedIn => _isLoggedIn;
  ThemePreference get themePreference => _themePreference;

  ThemeMode get themeMode => switch (_themePreference) {
        ThemePreference.light => ThemeMode.light,
        ThemePreference.dark => ThemeMode.dark,
        ThemePreference.system => ThemeMode.system,
      };

  bool get darkMode => _themePreference == ThemePreference.dark;
  String get languageCode => _languageCode;
  UserModel get currentUser => _currentUser;

  bool get showProposalSentCelebration => _showProposalSentCelebration;

  ThemeData get lightTheme =>
      AppTheme.lightTheme(dynamicScheme: _lightDynamic);
  ThemeData get darkTheme => AppTheme.darkTheme(dynamicScheme: _darkDynamic);

  String t(String en, String tr) => _languageCode == 'tr' ? tr : en;

  // ---------------------------------------------------------------------------
  // Dynamic colours
  // ---------------------------------------------------------------------------

  void setDynamicColorSchemes(ColorScheme? light, ColorScheme? dark) {
    bool same(ColorScheme? a, ColorScheme? b) {
      if (identical(a, b)) return true;
      if (a == null && b == null) return true;
      if (a == null || b == null) return false;
      return a.primary == b.primary &&
          a.brightness == b.brightness &&
          a.surface == b.surface;
    }

    if (same(_lightDynamic, light) && same(_darkDynamic, dark)) return;
    _lightDynamic = light;
    _darkDynamic = dark;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Proposal celebration
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Initialise
  // ---------------------------------------------------------------------------

  Future<void> initialize({JobsProvider? jobsProvider}) async {
    final prefs = await SharedPreferences.getInstance();
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

    if (SupabaseConfig.isEnabled) {
      _isLoggedIn = AuthService.instance.hasSession;
      if (_isLoggedIn) {
        final u = await AuthService.instance.loadProfileAsUserModel();
        if (u != null) _currentUser = u;
      }
      _authSubscription =
          AuthService.instance.authStateChanges().listen((data) async {
        final session = data.session;
        final next = session != null;
        _isLoggedIn = next;
        if (next) {
          final u = await AuthService.instance.loadProfileAsUserModel();
          if (u != null) _currentUser = u;
        } else {
          _currentUser = UserModel.dummy();
        }
        await jobsProvider?.refresh();
        notifyListeners();
      });
    } else {
      _isLoggedIn = false;
      _currentUser = UserModel.dummy();
    }

    await jobsProvider?.refresh();

    _isReady = true;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Auth actions
  // ---------------------------------------------------------------------------

  Future<bool> loginWithGoogle() async {
    if (!SupabaseConfig.isEnabled) return false;
    try {
      await AuthService.instance.signInWithGoogle();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> login({
    required String username,
    required String password,
    JobsProvider? jobsProvider,
  }) async {
    if (!SupabaseConfig.isEnabled) return false;
    try {
      await AuthService.instance.signInWithPassword(
        email: username,
        password: password,
      );
      _isLoggedIn = true;
      final u = await AuthService.instance.loadProfileAsUserModel();
      if (u != null) _currentUser = u;
      await jobsProvider?.refresh();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
    required bool isFreelancer,
  }) async {
    if (!SupabaseConfig.isEnabled) return;
    await AuthService.instance.signUp(
      email: email,
      password: password,
      fullName: name,
      isFreelancer: isFreelancer,
    );
    final u = await AuthService.instance.loadProfileAsUserModel();
    if (u != null) {
      _currentUser = u;
    } else {
      _currentUser = UserModel(
        id: AuthService.instance.rawUser?.id ?? _currentUser.id,
        name: name,
        email: email,
        avatarUrl:
            'https://i.pravatar.cc/150?img=${DateTime.now().millisecond % 60}',
        title: isFreelancer ? 'New Freelancer' : 'Project Owner',
        bio: isFreelancer ? 'New freelancer profile.' : 'New client profile.',
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
      await AuthService.instance.upsertProfileFromUserModel(_currentUser);
    }
    _isLoggedIn = AuthService.instance.hasSession;
    notifyListeners();
  }

  Future<void> logout() async {
    if (SupabaseConfig.isEnabled) {
      await AuthService.instance.signOut();
    }
    _isLoggedIn = false;
    _currentUser = UserModel.dummy();
    notifyListeners();
  }

  Future<void> changePassword(String nextPassword) async {
    if (SupabaseConfig.isEnabled) {
      await AuthService.instance.updatePassword(nextPassword);
    }
  }

  Future<void> updateUser(UserModel user) async {
    _currentUser = user;
    if (SupabaseConfig.isEnabled) {
      await AuthService.instance.upsertProfileFromUserModel(user);
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Theme / language
  // ---------------------------------------------------------------------------

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

  Future<void> setDarkMode(bool enabled) async {
    await setThemePreference(
      enabled ? ThemePreference.dark : ThemePreference.light,
    );
  }

  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _authSubscription?.cancel();
    _proposalCelebrationTimer?.cancel();
    super.dispose();
  }
}
