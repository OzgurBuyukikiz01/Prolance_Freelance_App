import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

/// Color variants for skill chips.
enum SkillChipVariant {
  primary,
  secondary,
  neutral,
}

/// A small rounded chip displaying a skill tag.
class SkillChip extends StatelessWidget {
  const SkillChip({
    super.key,
    required this.label,
    this.variant = SkillChipVariant.primary,
    this.onTap,
  });

  final String label;
  final SkillChipVariant variant;
  final VoidCallback? onTap;

  Color _getBackgroundColor() {
    switch (variant) {
      case SkillChipVariant.primary:
        return AppColors.primary.withValues(alpha: 0.12);
      case SkillChipVariant.secondary:
        return AppColors.secondary.withValues(alpha: 0.12);
      case SkillChipVariant.neutral:
        return AppColors.grey200;
    }
  }

  Color _getTextColor() {
    switch (variant) {
      case SkillChipVariant.primary:
        return AppColors.primary;
      case SkillChipVariant.secondary:
        return AppColors.secondary;
      case SkillChipVariant.neutral:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getTextColor().withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _getTextColor(),
            ),
          ),
        ),
      ),
    );
  }
}
