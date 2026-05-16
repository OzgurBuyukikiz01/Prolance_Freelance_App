import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';

enum ProlanceSnackVariant { info, success, error }

abstract final class ProlanceMessenger {
  static void show(
    BuildContext context,
    String message, {
    ProlanceSnackVariant variant = ProlanceSnackVariant.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;
    final scheme = Theme.of(context).colorScheme;
    final snackTheme = Theme.of(context).snackBarTheme;

    final (IconData icon, Color tint) = switch (variant) {
      ProlanceSnackVariant.success => (Iconsax.tick_circle, AppColors.success),
      ProlanceSnackVariant.error => (Iconsax.danger, AppColors.error),
      ProlanceSnackVariant.info => (Iconsax.info_circle, scheme.primary),
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: snackTheme.behavior ?? SnackBarBehavior.floating,
        duration: duration,
        backgroundColor: scheme.surfaceContainerHigh,
        shape: snackTheme.shape ??
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
        content: Row(
          children: [
            Icon(icon, color: tint, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: scheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void success(BuildContext context, String message) =>
      show(context, message, variant: ProlanceSnackVariant.success);

  static void error(BuildContext context, String message) =>
      show(context, message, variant: ProlanceSnackVariant.error);

  static void info(BuildContext context, String message) =>
      show(context, message, variant: ProlanceSnackVariant.info);
}
