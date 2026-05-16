import 'package:flutter/material.dart';

/// Prolance brand colors and semantic color definitions.
/// All colors used throughout the app should be defined here.
class AppColors {
  AppColors._();

  // ============ Brand Colors ============
  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFF00BFA6);
  static const Color background = Color(0xFFF8F9FE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFFF5252);

  // ============ Text Colors ============
  static const Color textPrimary = Color(0xFF1A1D26);
  static const Color textSecondary = Color(0xFF6B7280);

  // ============ Accent Colors ============
  static const Color accent = Color(0xFF6C63FF);
  static const Color accentLight = Color(0xFF9D9FFF);
  static const Color accentDark = Color(0xFF4F46E5);

  // ============ Semantic Colors ============
  static const Color success = Color(0xFF00BFA6);
  static const Color successLight = Color(0xFF5DF2D6);
  static const Color warning = Color(0xFFFFB74D);
  static const Color warningLight = Color(0xFFFFE0B2);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF90CAF9);

  // ============ Neutral Colors ============
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // ============ Dark Theme Colors ============
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E2E);
  static const Color darkSurfaceVariant = Color(0xFF2D2D3A);
  static const Color darkTextPrimary = Color(0xFFF8F9FE);
  static const Color darkTextSecondary = Color(0xFFB0B3C1);

  // ============ Gradients ============
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFF8B85FF)],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, Color(0xFF00E5CC)],
  );

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1E1E2E), Color(0xFF121212)],
  );
}
