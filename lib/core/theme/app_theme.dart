import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../constants/app_text_styles.dart';

/// Prolance themes built with FlexColorScheme (Material 3) around brand seed colors,
/// optionally augmented by Android 12+ dynamic [ColorScheme] from Material You.
class AppTheme {
  AppTheme._();

  /// Fallback schemes anchored on brand purple/teal when dynamic colors are unavailable.
  static ColorScheme _fallbackLightScheme() => ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        secondary: AppColors.secondary,
        brightness: Brightness.light,
      );

  static ColorScheme _fallbackDarkScheme() => ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        secondary: AppColors.secondary,
        brightness: Brightness.dark,
      );

  /// Pulls dark foregrounds and surfaces toward white so text/icons never read as "black"
  /// on charcoal surfaces (Flex blend + seed schemes can sit too low-contrast).
  static ColorScheme elevateDarkScheme(ColorScheme scheme) {
    if (scheme.brightness != Brightness.dark) return scheme;
    Color lift(Color c, double t) => Color.lerp(c, Colors.white, t)!;
    return scheme.copyWith(
      onSurface: lift(scheme.onSurface, 0.13),
      onSurfaceVariant: lift(scheme.onSurfaceVariant, 0.17),
      outline: lift(scheme.outline, 0.12),
      outlineVariant: lift(scheme.outlineVariant, 0.14),
      surface: lift(scheme.surface, 0.042),
      surfaceContainerLowest: lift(scheme.surfaceContainerLowest, 0.036),
      surfaceContainerLow: lift(scheme.surfaceContainerLow, 0.04),
      surfaceContainer: lift(scheme.surfaceContainer, 0.046),
      surfaceContainerHigh: lift(scheme.surfaceContainerHigh, 0.05),
      surfaceContainerHighest: lift(scheme.surfaceContainerHighest, 0.056),
    );
  }

  static ThemeData lightTheme({ColorScheme? dynamicScheme}) {
    final scheme = dynamicScheme ?? _fallbackLightScheme();
    final base = FlexThemeData.light(
      colorScheme: scheme,
      useMaterial3: true,
      fontFamily: GoogleFonts.poppins().fontFamily,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 14,
      appBarStyle: FlexAppBarStyle.surface,
      subThemesData: FlexSubThemesData(
        defaultRadius: AppConstants.radiusMd,
        elevatedButtonRadius: AppConstants.radiusMd,
        outlinedButtonRadius: AppConstants.radiusMd,
        inputDecoratorRadius: AppConstants.radiusMd,
        chipRadius: AppConstants.radiusSm,
        useMaterial3Typography: true,
        elevatedButtonElevation: 0,
        navigationBarElevation: 2,
        inputDecoratorSchemeColor: SchemeColor.primary,
        elevatedButtonSchemeColor: SchemeColor.primary,
        outlinedButtonOutlineSchemeColor: SchemeColor.primary,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: scheme.surfaceContainerLowest,
      textTheme: _mergeBrandTypography(
        base.textTheme,
        scheme.onSurface,
        scheme.onSurfaceVariant,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.35),
        thickness: 1,
      ),
    );
  }

  static ThemeData darkTheme({ColorScheme? dynamicScheme}) {
    final scheme =
        elevateDarkScheme(dynamicScheme ?? _fallbackDarkScheme());
    final base = FlexThemeData.dark(
      colorScheme: scheme,
      useMaterial3: true,
      fontFamily: GoogleFonts.poppins().fontFamily,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 14,
      appBarStyle: FlexAppBarStyle.surface,
      subThemesData: FlexSubThemesData(
        defaultRadius: AppConstants.radiusMd,
        elevatedButtonRadius: AppConstants.radiusMd,
        outlinedButtonRadius: AppConstants.radiusMd,
        inputDecoratorRadius: AppConstants.radiusMd,
        chipRadius: AppConstants.radiusSm,
        useMaterial3Typography: true,
        elevatedButtonElevation: 0,
        navigationBarElevation: 2,
        inputDecoratorSchemeColor: SchemeColor.primary,
        elevatedButtonSchemeColor: SchemeColor.primary,
        outlinedButtonOutlineSchemeColor: SchemeColor.primary,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: scheme.surfaceContainerLowest,
      iconTheme: IconThemeData(color: scheme.onSurface),
      primaryIconTheme: IconThemeData(color: scheme.onSurface),
      textTheme: _mergeBrandTypography(
        base.textTheme,
        scheme.onSurface,
        scheme.onSurfaceVariant,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.35),
        thickness: 1,
      ),
    );
  }

  static TextTheme _mergeBrandTypography(
    TextTheme base,
    Color onSurface,
    Color onSurfaceVariant,
  ) {
    final branded = _semanticTextTheme(onSurface, onSurfaceVariant);
    return base.copyWith(
      displayLarge: branded.displayLarge,
      displayMedium: branded.displayMedium,
      displaySmall: branded.displaySmall,
      headlineLarge: branded.headlineLarge,
      headlineMedium: branded.headlineMedium,
      headlineSmall: branded.headlineSmall,
      titleLarge: branded.titleLarge,
      titleMedium: branded.titleMedium,
      titleSmall: branded.titleSmall,
      bodyLarge: branded.bodyLarge,
      bodyMedium: branded.bodyMedium,
      bodySmall: branded.bodySmall,
      labelLarge: branded.labelLarge,
      labelMedium: branded.labelMedium,
      labelSmall: branded.labelSmall,
    );
  }

  static TextTheme _semanticTextTheme(Color primaryColor, Color secondaryColor) {
    return TextTheme(
      displayLarge: AppTextStyles.heading1.copyWith(color: primaryColor),
      displayMedium: AppTextStyles.heading2.copyWith(color: primaryColor),
      displaySmall: AppTextStyles.heading3.copyWith(color: primaryColor),
      headlineLarge: AppTextStyles.heading4.copyWith(color: primaryColor),
      headlineMedium: AppTextStyles.heading5.copyWith(color: primaryColor),
      headlineSmall: AppTextStyles.heading6.copyWith(color: primaryColor),
      titleLarge: AppTextStyles.bodyLarge.copyWith(
        color: primaryColor,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: AppTextStyles.bodyMedium.copyWith(
        color: primaryColor,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: AppTextStyles.bodySmall.copyWith(
        color: primaryColor,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: primaryColor),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: primaryColor),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: secondaryColor),
      labelLarge: AppTextStyles.buttonMedium.copyWith(color: primaryColor),
      labelMedium: AppTextStyles.label.copyWith(color: primaryColor),
      labelSmall: AppTextStyles.labelSmall.copyWith(color: secondaryColor),
    );
  }
}
