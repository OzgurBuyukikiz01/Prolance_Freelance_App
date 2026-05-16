/// Supabase project URL and anon key.
///
/// Local defaults match `supabase start` (see [docs/supabase-local.md](docs/supabase-local.md)).
/// Override with `--dart-define=SUPABASE_URL=...` and `--dart-define=SUPABASE_ANON_KEY=...`.
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
    defaultValue: 'http://127.0.0.1:54321',
  );

  /// Local Supabase demo JWT (role: anon). Replace in production.
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0',
  );

  static bool get isEnabled =>
      useSupabase.toLowerCase() != 'false' &&
      url.isNotEmpty &&
      anonKey.isNotEmpty;
}
