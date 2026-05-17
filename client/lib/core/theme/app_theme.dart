import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  /// Shared overrides applied to both light and dark themes.
  static ThemeData _applySharedOverrides(ThemeData base, ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    return base.copyWith(
      scaffoldBackgroundColor: scheme.surfaceContainerLowest,
      splashFactory: InkSparkle.splashFactory,
      iconTheme: IconThemeData(color: scheme.onSurface),
      primaryIconTheme: IconThemeData(color: scheme.onSurface),
      textTheme: _mergeBrandTypography(
        base.textTheme,
        scheme.onSurface,
        scheme.onSurfaceVariant,
      ),
      // Card — consistent rounded corners + subtle shadow
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          side: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      // Chips — pill shape, tighter padding
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        ),
        labelPadding:
            const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        labelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: scheme.onSurface,
        ),
      ),
      // Input decoration — filled, rounded, no underline
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: BorderSide(
              color: scheme.outlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: scheme.onSurfaceVariant,
        ),
      ),
      // Elevated button — gradient wrapper used in app; keep shape
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      // Outlined button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: scheme.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          minimumSize: const Size(double.infinity, 52),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      // Bottom sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        clipBehavior: Clip.antiAlias,
        dragHandleColor: scheme.outlineVariant,
        showDragHandle: true,
        dragHandleSize: const Size(40, 4),
      ),
      // Snackbar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.surfaceContainerHigh,
        contentTextStyle: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: scheme.onSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
      ),
      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        ),
        elevation: 8,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
        contentTextStyle: GoogleFonts.poppins(
          fontSize: 14,
          height: 1.45,
          color: scheme.onSurfaceVariant,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      ),
      // Page transitions — subtle fade+slide for modern feel
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.35),
        thickness: 1,
      ),
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
      subThemesData: const FlexSubThemesData(
        defaultRadius: AppConstants.radiusMd,
        elevatedButtonRadius: AppConstants.radiusMd,
        outlinedButtonRadius: AppConstants.radiusMd,
        inputDecoratorRadius: AppConstants.radiusMd,
        chipRadius: AppConstants.radiusSm,
        useMaterial3Typography: true,
        elevatedButtonElevation: 0,
        navigationBarElevation: 0,
        inputDecoratorSchemeColor: SchemeColor.primary,
        elevatedButtonSchemeColor: SchemeColor.primary,
        outlinedButtonOutlineSchemeColor: SchemeColor.primary,
      ),
    );
    return _applySharedOverrides(base, scheme);
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
      subThemesData: const FlexSubThemesData(
        defaultRadius: AppConstants.radiusMd,
        elevatedButtonRadius: AppConstants.radiusMd,
        outlinedButtonRadius: AppConstants.radiusMd,
        inputDecoratorRadius: AppConstants.radiusMd,
        chipRadius: AppConstants.radiusSm,
        useMaterial3Typography: true,
        elevatedButtonElevation: 0,
        navigationBarElevation: 0,
        inputDecoratorSchemeColor: SchemeColor.primary,
        elevatedButtonSchemeColor: SchemeColor.primary,
        outlinedButtonOutlineSchemeColor: SchemeColor.primary,
      ),
    );
    return _applySharedOverrides(base, scheme);
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
