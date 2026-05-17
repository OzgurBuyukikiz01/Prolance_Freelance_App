import 'package:flutter/material.dart';

/// Prolance brand colors — "Electric Violet & Ocean Mint" palette.
/// Full shade scales (50–950) for primary, secondary, accent, neutral.
class AppColors {
  AppColors._();

  // ============ Primary — Electric Violet (brand) ============
  static const Color primary50  = Color(0xFFF3F0FF);
  static const Color primary100 = Color(0xFFE9E3FF);
  static const Color primary200 = Color(0xFFD4C9FF);
  static const Color primary300 = Color(0xFFB5A3FF);
  static const Color primary400 = Color(0xFF9075FF);
  static const Color primary500 = Color(0xFF7248FE);
  static const Color primary600 = Color(0xFF5E2FE8);
  static const Color primary700 = Color(0xFF4B1EC7);
  static const Color primary800 = Color(0xFF3C19A0);
  static const Color primary900 = Color(0xFF2E1580);
  static const Color primary950 = Color(0xFF1A0A4A);

  static const Color primary = primary500;

  // ============ Secondary — Ocean Mint ============
  static const Color secondary50 = Color(0xFFEDFDF8);
  static const Color secondary100 = Color(0xFFD2F9EE);
  static const Color secondary200 = Color(0xFFA8F2DC);
  static const Color secondary300 = Color(0xFF6AE8C5);
  static const Color secondary400 = Color(0xFF2DD5A8);
  static const Color secondary500 = Color(0xFF0EBD90);
  static const Color secondary600 = Color(0xFF059873);
  static const Color secondary700 = Color(0xFF077A5D);
  static const Color secondary800 = Color(0xFF085F49);
  static const Color secondary900 = Color(0xFF064E3C);
  static const Color secondary950 = Color(0xFF022B21);

  static const Color secondary = secondary500;

  // ============ Accent — Electric Coral ============
  static const Color accent50  = Color(0xFFFFF4F0);
  static const Color accent100 = Color(0xFFFFE4D9);
  static const Color accent200 = Color(0xFFFFC4AA);
  static const Color accent300 = Color(0xFFFF9E7A);
  static const Color accent400 = Color(0xFFFF7A52);
  static const Color accent500 = Color(0xFFFF5833);
  static const Color accent600 = Color(0xFFE63F1A);
  static const Color accent700 = Color(0xFFC22E10);
  static const Color accent800 = Color(0xFF9A230C);
  static const Color accent900 = Color(0xFF7A1C0A);
  static const Color accent950 = Color(0xFF3D0A03);

  static const Color accent = accent500;

  // ============ Neutral — Warm Slate ============
  static const Color neutral50 = Color(0xFFF9F8F7);
  static const Color neutral100 = Color(0xFFF2F0EE);
  static const Color neutral200 = Color(0xFFE6E2DE);
  static const Color neutral300 = Color(0xFFCFC8C0);
  static const Color neutral400 = Color(0xFFB0A69A);
  static const Color neutral500 = Color(0xFF8D8178);
  static const Color neutral600 = Color(0xFF6B6059);
  static const Color neutral700 = Color(0xFF504740);
  static const Color neutral800 = Color(0xFF352E28);
  static const Color neutral900 = Color(0xFF1E1812);
  static const Color neutral950 = Color(0xFF100E0A);

  // ============ Semantic Colors ============
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color successDark = Color(0xFF15803D);

  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFFB45309);

  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFFB91C1C);

  static const Color info = Color(0xFF0EA5E9);
  static const Color infoLight = Color(0xFFE0F2FE);

  // ============ Base Colors ============
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // ============ Text Colors ============
  static const Color textPrimary = Color(0xFF1E1812);
  static const Color textSecondary = Color(0xFF6B6059);
  static const Color textTertiary = Color(0xFF8D8178);

  // ============ Background / Surface ============
  static const Color background = Color(0xFFF9F8F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF2F0EE);

  // ============ Dark Theme ============
  static const Color darkBackground = Color(0xFF0A0F1E);
  static const Color darkSurface = Color(0xFF0F1628);
  static const Color darkSurfaceVariant = Color(0xFF14203A);
  static const Color darkTextPrimary = Color(0xFFF9F8F7);
  static const Color darkTextSecondary = Color(0xFFB0A69A);

  // ============ Glass / Frosted UI ============
  static const Color glassWhite = Color(0x14FFFFFF);
  static const Color glassBorder = Color(0x1AFFFFFF);
  static const Color glassWhiteStrong = Color(0x29FFFFFF);
  static const Color glassBorderStrong = Color(0x2EFFFFFF);

  // ============ Gradients ============
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary500, primary400], // violet
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary500, secondary400],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent500, accent400],
  );

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary500, accent500],
  );

  static const LinearGradient violetGradient2 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7248FE), Color(0xFF9075FF)],
  );

  static const LinearGradient coralGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF5833), Color(0xFFFF8A65)],
  );

  static const LinearGradient mintGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0EBD90), Color(0xFF2DD5A8)],
  );

  static const LinearGradient violetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7248FE), Color(0xFF9075FF)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [darkSurface, darkBackground],
  );

  // Onboarding slide gradients
  static const LinearGradient onboardSlide1 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF5833), Color(0xFFFF8A65)],
  );

  static const LinearGradient onboardSlide2 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0EBD90), Color(0xFF2DD5A8)],
  );

  static const LinearGradient onboardSlide3 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7248FE), Color(0xFF9075FF)],
  );

  static const LinearGradient onboardSlide4 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF5833), Color(0xFF7248FE)],
  );

  // ============ Legacy Aliases (backward-compat) ============
  static const Color accentLight = accent300;
  static const Color accentDark = accent700;
  static const Color grey100 = neutral100;
  static const Color grey200 = neutral200;
  static const Color grey300 = neutral300;
  static const Color grey400 = neutral400;
  static const Color grey500 = neutral500;
  static const Color grey600 = neutral600;
  static const Color grey700 = neutral700;
  static const Color grey800 = neutral800;
  static const Color grey900 = neutral900;
}
