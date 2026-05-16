/// Persisted appearance preference — mapped to Flutter [ThemeMode].
enum ThemePreference {
  light,
  dark,
  system;

  static ThemePreference fromStored(String? raw) {
    if (raw == null || raw.isEmpty) return ThemePreference.system;
    for (final v in ThemePreference.values) {
      if (v.name == raw) return v;
    }
    return ThemePreference.system;
  }
}
