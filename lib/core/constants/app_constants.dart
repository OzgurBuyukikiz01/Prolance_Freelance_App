/// Prolance app-wide constants including layout, animation, and content values.
class AppConstants {
  AppConstants._();

  // ============ App Info ============
  static const String appName = 'Prolance';

  // ============ Animation Durations ============
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationVerySlow = Duration(milliseconds: 800);

  // ============ Padding Values ============
  static const double paddingXs = 4.0;
  static const double paddingSm = 8.0;
  static const double paddingMd = 16.0;
  static const double paddingLg = 24.0;
  static const double paddingXl = 32.0;
  static const double paddingXxl = 48.0;

  // ============ Border Radius Values ============
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;

  // ============ Job Categories ============
  static const List<String> jobCategories = [
    'Mobile Development',
    'Web Development',
    'UI/UX Design',
    'Data Science',
    'Cloud & DevOps',
    'Graphic Design',
    'Content Writing',
    'Video Editing',
    'Digital Marketing',
    'Blockchain',
  ];
}
