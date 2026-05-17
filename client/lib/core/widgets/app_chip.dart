import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

enum ChipVariant { filled, soft, outlined, ghost }
enum ChipSize { sm, md, lg }

/// Unified chip widget replacing both CategoryChip and SkillChip.
///
/// Usage:
/// ```dart
/// AppChip(label: 'Flutter', variant: ChipVariant.soft)
/// AppChip(label: 'Mobile Dev', variant: ChipVariant.filled, selected: true)
/// ```
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.variant = ChipVariant.soft,
    this.size = ChipSize.md,
    this.selected = false,
    this.onTap,
    this.onRemove,
    this.icon,
    this.color,
  });

  final String label;
  final ChipVariant variant;
  final ChipSize size;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final IconData? icon;
  final Color? color;

  Color get _base => color ?? AppColors.primary500;

  double get _fontSize => switch (size) {
        ChipSize.sm => 11,
        ChipSize.md => 12,
        ChipSize.lg => 14,
      };

  EdgeInsets get _padding => switch (size) {
        ChipSize.sm => const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        ChipSize.md => const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ChipSize.lg => const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      };

  Color get _bg => switch (variant) {
        ChipVariant.filled   => selected ? _base : _base.withValues(alpha: 0.85),
        ChipVariant.soft     => selected
            ? _base.withValues(alpha: 0.18)
            : _base.withValues(alpha: 0.10),
        ChipVariant.outlined => Colors.transparent,
        ChipVariant.ghost    => Colors.transparent,
      };

  Color get _fg => switch (variant) {
        ChipVariant.filled   => AppColors.white,
        ChipVariant.soft     => selected ? _base : AppColors.neutral700,
        ChipVariant.outlined => _base,
        ChipVariant.ghost    => AppColors.neutral600,
      };

  Border? get _border => switch (variant) {
        ChipVariant.outlined => Border.all(
            color: selected ? _base : AppColors.neutral300,
            width: 1.5,
          ),
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: _padding,
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          border: _border,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: _fontSize + 2, color: _fg),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: _fontSize,
                fontWeight: FontWeight.w500,
                color: _fg,
              ),
            ),
            if (onRemove != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onRemove,
                child: Icon(Icons.close_rounded, size: _fontSize + 1, color: _fg),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
