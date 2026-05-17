/// Prolance app-wide constants including layout, animation, and content values.
class AppConstants {
  AppConstants._();

  // ============ App Info ============
  static const String appName = 'Prolance';

  // ============ Animation Durations ============
  static const Duration animationInstant = Duration(milliseconds: 100);
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationVerySlow = Duration(milliseconds: 800);

  // Legacy alias kept for compatibility
  static const Duration animationFastLegacy = Duration(milliseconds: 150);

  // ============ Spacing / Padding Values ============
  static const double space1 = 4.0;
  static const double space2 = 8.0;
  static const double space3 = 12.0;
  static const double space4 = 16.0;
  static const double space5 = 20.0;
  static const double space6 = 24.0;
  static const double space8 = 32.0;
  static const double space10 = 40.0;
  static const double space12 = 48.0;
  static const double space16 = 64.0;
  static const double space20 = 80.0;
  static const double space24 = 96.0;

  // Legacy aliases
  static const double paddingXs = space1;
  static const double paddingSm = space2;
  static const double paddingMd = space4;
  static const double paddingLg = space6;
  static const double paddingXl = space8;
  static const double paddingXxl = space12;

  // ============ Border Radius Values ============
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radius2xl = 24.0;
  static const double radius3xl = 32.0;
  static const double radiusFull = 999.0;

  /// Post-job wizard categories — single source for filters and skills JSON keys.
  static const List<String> postJobCategories = [
    'Mobile Dev',
    'Web Dev',
    'UI/UX Design',
    'Data Science',
    'Cloud & DevOps',
    'Graphic Design',
    'Content Writing',
    'Video Editing',
    'Digital Marketing',
    'Blockchain',
  ];

  /// Jobs browse filter chip options (aligned with [postJobCategories]).
  static const List<String> jobCategories = postJobCategories;

  /// Home horizontal chips after "All" (substring match against [JobModel.category]).
  static const List<String> homeCategoryChips = [
    'Mobile Dev',
    'Web Dev',
    'UI/UX',
    'Data Science',
    'Design',
    'Writing',
    'Marketing',
  ];
}
