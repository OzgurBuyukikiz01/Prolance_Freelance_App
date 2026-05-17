import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/user_model.dart';

/// Wraps Supabase Auth + [profiles] row sync into [UserModel].
class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  SupabaseClient? get _client {
    if (!SupabaseConfig.isEnabled) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  User? get rawUser => _client?.auth.currentUser;

  bool get hasSession => _client?.auth.currentSession != null;

  /// JWT access token (Supabase-issued). Decode with [jwt_decoder] if needed.
  String? get accessToken => _client?.auth.currentSession?.accessToken;

  Stream<AuthState> authStateChanges() {
    if (_client == null) {
      return const Stream.empty();
    }
    return _client!.auth.onAuthStateChange;
  }

  static const String mobileOAuthRedirect = 'io.prolance.app://login-callback';

  Future<void> signInWithGoogle() async {
    final c = _client;
    if (c == null) {
      throw StateError('Supabase is not enabled');
    }
    await c.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? null : mobileOAuthRedirect,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final c = _client;
    if (c == null) {
      throw StateError('Supabase is not enabled');
    }
    return c.auth.signInWithPassword(email: email.trim(), password: password);
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required bool isFreelancer,
  }) async {
    final c = _client;
    if (c == null) {
      throw StateError('Supabase is not enabled');
    }
    final role = isFreelancer ? 'FREELANCER' : 'CLIENT';
    return c.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'full_name': fullName,
        'role': role,
      },
    );
  }

  Future<void> signOut() async {
    await _client?.auth.signOut();
  }

  Future<void> resetPasswordForEmail(String email) async {
    final c = _client;
    if (c == null) return;
    await c.auth.resetPasswordForEmail(email.trim());
  }

  Future<void> updatePassword(String newPassword) async {
    final c = _client;
    if (c == null) return;
    await c.auth.updateUser(UserAttributes(password: newPassword));
  }

  /// Loads [profiles] row for [rawUser] and maps to [UserModel].
  Future<UserModel?> loadProfileAsUserModel() async {
    final c = _client;
    final u = rawUser;
    if (c == null || u == null) return null;

    final row = await c
        .from('profiles')
        .select()
        .eq('id', u.id)
        .maybeSingle();

    if (row == null) {
      return UserModel(
        id: u.id,
        name: u.userMetadata?['full_name'] as String? ?? u.email ?? 'User',
        email: u.email ?? '',
        avatarUrl: u.userMetadata?['avatar_url'] as String? ?? '',
        title: '',
        bio: '',
        hourlyRate: 0,
        website: '',
        rating: 0,
        completedJobs: 0,
        totalEarnings: 0,
        skills: const [],
        location: 'Remote',
        isFreelancer: true,
        isAdmin: false,
        demoBalanceCents: 0,
        earningsAvailableCents: 0,
        joinedDate: DateTime.tryParse(u.createdAt) ?? DateTime.now(),
      );
    }

    final skillsRaw = row['skills'];
    final skills = skillsRaw is List
        ? skillsRaw.map((e) => '$e').toList()
        : <String>[];

    final role = '${row['role']}';
    final isFreelancer = role != 'CLIENT';

    final isAdmin = row['is_admin'] == true;

    return UserModel(
      id: row['id'] as String,
      name: row['full_name'] as String? ?? '',
      email: row['email'] as String? ?? u.email ?? '',
      avatarUrl: row['avatar_url'] as String? ?? '',
      title: row['title'] as String? ?? '',
      bio: row['bio'] as String? ?? '',
      hourlyRate: (row['hourly_rate'] as num?)?.toDouble() ?? 0,
      website: row['website'] as String? ?? '',
      rating: (row['rating'] as num?)?.toDouble() ?? 0,
      completedJobs: (row['completed_jobs'] as num?)?.toInt() ?? 0,
      totalEarnings: (row['total_earnings'] as num?)?.toInt() ?? 0,
      skills: skills,
      location: row['location'] as String? ?? 'Remote',
      isFreelancer: isFreelancer,
      isAdmin: isAdmin,
      demoBalanceCents: (row['demo_balance_cents'] as num?)?.toInt() ?? 0,
      earningsAvailableCents:
          (row['earnings_available_cents'] as num?)?.toInt() ?? 0,
      joinedDate: DateTime.tryParse('${row['created_at']}') ?? DateTime.now(),
    );
  }

  Future<void> upsertProfileFromUserModel(UserModel user) async {
    final c = _client;
    if (c == null) return;
    final uid = rawUser?.id;
    if (uid == null) {
      throw StateError(
        'No authenticated session. Sign in again to save your profile.',
      );
    }

    final payload = <String, dynamic>{
      'email': user.email,
      'full_name': user.name,
      'avatar_url': user.avatarUrl,
      'title': user.title,
      'bio': user.bio,
      'hourly_rate': user.hourlyRate,
      'website': user.website,
      'rating': user.rating,
      'completed_jobs': user.completedJobs,
      'total_earnings': user.totalEarnings,
      'skills': user.skills,
      'location': user.location,
      'role': user.isFreelancer ? 'FREELANCER' : 'CLIENT',
    };

    final updated =
        await c.from('profiles').update(payload).eq('id', uid).select('id').maybeSingle();

    if (updated == null) {
      await c.from('profiles').insert({
        'id': uid,
        ...payload,
      });
    }
  }

  static Future<void> initializeIfEnabled() async {
    if (!SupabaseConfig.isEnabled) {
      debugPrint('Supabase: disabled (USE_SUPABASE=false or missing config).');
      return;
    }
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
    debugPrint('Supabase: initialized at ${SupabaseConfig.url}');
  }
}
