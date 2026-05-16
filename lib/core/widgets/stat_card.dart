import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

/// A small card displaying a stat with icon, value, and label.
/// Supports gradient background option.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.useGradient = false,
    this.iconColor,
    this.valueColor,
    this.labelColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final bool useGradient;
  final Color? iconColor;
  final Color? valueColor;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final effectiveIconColor = iconColor ?? AppColors.primary;
    final effectiveValueColor = valueColor ?? scheme.onSurface;
    final effectiveLabelColor = labelColor ?? scheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: useGradient ? AppColors.primaryGradient : null,
        color: useGradient ? null : scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: useGradient ? 0.2 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (useGradient ? AppColors.white : effectiveIconColor)
                  .withValues(alpha: useGradient ? 0.2 : 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 24,
              color: useGradient ? AppColors.white : effectiveIconColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: useGradient ? AppColors.white : effectiveValueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: useGradient
                  ? AppColors.white.withValues(alpha: 0.9)
                  : effectiveLabelColor,
            ),
          ),
        ],
      ),
    );
  }
}
