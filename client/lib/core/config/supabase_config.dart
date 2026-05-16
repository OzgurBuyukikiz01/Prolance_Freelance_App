/// Supabase project URL and anon key.
///
/// Local defaults match `supabase start` (see [docs/supabase-local.md](docs/supabase-local.md)).
///
/// **Production:** pass real cloud values on every release build (CI / store):
/// ```bash
/// flutter build web --release \
///   --dart-define=SUPABASE_URL=https://cgxzpdhcaxiopdylwstr.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNneHpwZGhjYXhpb3BkeWx3c3RyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg5NDIzNzksImV4cCI6MjA5NDUxODM3OX0.lNOk6lL3CmMFh8gXoA6hrnW1QcWxpaz2sTTKVOY83fg
/// ```
/// Same defines apply to `flutter build apk` / `flutter build ios`.
///
/// Set `--dart-define=USE_SUPABASE=false` to disable initialization (offline / tests).
class SupabaseConfig {
  SupabaseConfig._();

  static const String useSupabase = String.fromEnvironment(
    'USE_SUPABASE',
    defaultValue: 'true',
  );

  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    // Cloud project — override with --dart-define=SUPABASE_URL=... for local dev
    defaultValue: 'https://cgxzpdhcaxiopdylwstr.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNneHpwZGhjYXhpb3BkeWx3c3RyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg5NDIzNzksImV4cCI6MjA5NDUxODM3OX0.lNOk6lL3CmMFh8gXoA6hrnW1QcWxpaz2sTTKVOY83fg',
  );

  static bool get isEnabled =>
      useSupabase.toLowerCase() != 'false' &&
      url.isNotEmpty &&
      anonKey.isNotEmpty;
}
