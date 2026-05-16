import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Prolance typography using Google Fonts Poppins.
///
/// Font metrics only — **do not** bake in light-theme text colors here.
/// Apply `Theme.of(context).colorScheme` / `Theme.of(context).textTheme` for colors,
/// or let [AppTheme] merge brand colors from the active [ColorScheme].
class AppTextStyles {
  AppTextStyles._();

  // ============ Headings ============
  static TextStyle get heading1 => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      );

  static TextStyle get heading2 => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      );

  static TextStyle get heading3 => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      );

  static TextStyle get heading4 => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get heading5 => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get heading6 => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      );

  // ============ Body Text ============
  static TextStyle get bodyLarge => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  // ============ Body Text — muted (use with ColorScheme.onSurfaceVariant) ============
  static TextStyle get bodyLargeSecondary => bodyLarge;

  static TextStyle get bodyMediumSecondary => bodyMedium;

  static TextStyle get bodySmallSecondary => bodySmall;

  // ============ Caption & Label ============
  static TextStyle get caption => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get captionBold => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get label => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get labelSmall => GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
      );

  // ============ Button Text ============
  static TextStyle get buttonLarge => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );

  static TextStyle get buttonMedium => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );

  static TextStyle get buttonSmall => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );

  // ============ Overline ============
  static TextStyle get overline => GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      );
}
