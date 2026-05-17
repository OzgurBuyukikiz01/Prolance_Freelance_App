import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

// ─── AppButton — new unified button system ────────────────────────────────────

enum ButtonVariant { filled, outlined, soft, ghost, destructive }
enum ButtonSize { sm, md, lg }
enum IconPosition { leading, trailing }

/// Unified button with variant + size system, spring press animation, and
/// optional coral gradient on filled variant.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.filled,
    this.size = ButtonSize.md,
    this.icon,
    this.iconPosition = IconPosition.leading,
    this.isLoading = false,
    this.fullWidth = true,
    this.useGradient = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final IconData? icon;
  final IconPosition iconPosition;
  final bool isLoading;
  final bool fullWidth;
  final bool useGradient;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: AppMotionDurations.instant,
    );
    _scale = Tween(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  double get _height => switch (widget.size) {
        ButtonSize.sm => 40,
        ButtonSize.md => 52,
        ButtonSize.lg => 60,
      };

  double get _fontSize => switch (widget.size) {
        ButtonSize.sm => 13,
        ButtonSize.md => 15,
        ButtonSize.lg => 17,
      };

  double get _iconSize => switch (widget.size) {
        ButtonSize.sm => 16,
        ButtonSize.md => 20,
        ButtonSize.lg => 22,
      };

  _ButtonStyle get _style {
    return switch (widget.variant) {
      ButtonVariant.filled => _ButtonStyle(
          bg: null,
          gradient: widget.useGradient ? AppColors.coralGradient : null,
          solidBg: widget.useGradient ? null : AppColors.primary500,
          border: null,
          fg: AppColors.white,
          shadow: BoxShadow(
            color: AppColors.primary500.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ),
      ButtonVariant.outlined => _ButtonStyle(
          bg: Colors.transparent,
          gradient: null,
          solidBg: null,
          border: Border.all(color: AppColors.primary500, width: 2),
          fg: AppColors.primary500,
          shadow: null,
        ),
      ButtonVariant.soft => _ButtonStyle(
          bg: AppColors.primary100,
          gradient: null,
          solidBg: null,
          border: null,
          fg: AppColors.primary700,
          shadow: null,
        ),
      ButtonVariant.ghost => _ButtonStyle(
          bg: Colors.transparent,
          gradient: null,
          solidBg: null,
          border: null,
          fg: AppColors.primary500,
          shadow: null,
        ),
      ButtonVariant.destructive => _ButtonStyle(
          bg: AppColors.error,
          gradient: null,
          solidBg: null,
          border: null,
          fg: AppColors.white,
          shadow: BoxShadow(
            color: AppColors.error.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final s = _style;
    final disabled = widget.onPressed == null && !widget.isLoading;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: AnimatedOpacity(
          opacity: disabled ? 0.45 : 1.0,
          duration: AppMotionDurations.fast,
          child: Container(
            height: _height,
            width: widget.fullWidth ? double.infinity : null,
            decoration: BoxDecoration(
              gradient: s.gradient,
              color: s.gradient == null ? (s.solidBg ?? s.bg) : null,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              border: s.border,
              boxShadow: s.shadow != null ? [s.shadow!] : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: (disabled || widget.isLoading) ? null : widget.onPressed,
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                splashColor: s.fg.withValues(alpha: 0.12),
                highlightColor: s.fg.withValues(alpha: 0.08),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: switch (widget.size) {
                      ButtonSize.sm => 16,
                      ButtonSize.md => 20,
                      ButtonSize.lg => 24,
                    },
                  ),
                  child: Center(
                    child: widget.isLoading
                        ? SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(s.fg),
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (widget.icon != null &&
                                  widget.iconPosition == IconPosition.leading) ...[
                                Icon(widget.icon, size: _iconSize, color: s.fg),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                widget.label,
                                style: GoogleFonts.poppins(
                                  fontSize: _fontSize,
                                  fontWeight: FontWeight.w600,
                                  color: s.fg,
                                ),
                              ),
                              if (widget.icon != null &&
                                  widget.iconPosition == IconPosition.trailing) ...[
                                const SizedBox(width: 8),
                                Icon(widget.icon, size: _iconSize, color: s.fg),
                              ],
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ButtonStyle {
  const _ButtonStyle({
    required this.bg,
    required this.gradient,
    required this.solidBg,
    required this.border,
    required this.fg,
    required this.shadow,
  });
  final Color? bg;
  final Gradient? gradient;
  final Color? solidBg;
  final Border? border;
  final Color fg;
  final BoxShadow? shadow;
}

// Inline duration constants to avoid circular import with AppConstants
class AppMotionDurations {
  static const instant = Duration(milliseconds: 100);
  static const fast = Duration(milliseconds: 200);
}

// ─── Legacy CustomButton (backward-compat alias) ───────────────────────────

/// A filled button with rounded corners, gradient option, loading state, and icon.
class CustomButton extends StatefulWidget {
  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.iconPosition = IconPosition.leading,
    this.isLoading = false,
    this.useGradient = false,
    this.borderRadius = 12,
    this.height = 52,
    this.textColor = AppColors.white,
    this.backgroundColor,
    this.gradient,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconPosition iconPosition;
  final bool isLoading;
  final bool useGradient;
  final double borderRadius;
  final double height;
  final Color textColor;
  final Color? backgroundColor;
  final Gradient? gradient;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

// ignore: library_private_types_in_public_api
class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = widget.gradient ??
        (widget.useGradient ? AppColors.primaryGradient : null);
    final backgroundColor = widget.backgroundColor ?? AppColors.primary;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: AnimatedOpacity(
          opacity: widget.onPressed == null && !widget.isLoading ? 0.5 : 1,
          duration: const Duration(milliseconds: 200),
          child: Container(
            height: widget.height,
            decoration: BoxDecoration(
              gradient: gradient,
              color: gradient == null ? backgroundColor : null,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.isLoading ? null : widget.onPressed,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: Center(
                  child: widget.isLoading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              widget.textColor,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.icon != null &&
                                widget.iconPosition == IconPosition.leading) ...[
                              Icon(
                                widget.icon,
                                size: 20,
                                color: widget.textColor,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              widget.label,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: widget.textColor,
                              ),
                            ),
                            if (widget.icon != null &&
                                widget.iconPosition == IconPosition.trailing) ...[
                              const SizedBox(width: 8),
                              Icon(
                                widget.icon,
                                size: 20,
                                color: widget.textColor,
                              ),
                            ],
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// An outlined button variant with tap animations.
class CustomOutlinedButton extends StatefulWidget {
  const CustomOutlinedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.iconPosition = IconPosition.leading,
    this.isLoading = false,
    this.borderRadius = 12,
    this.height = 52,
    this.borderColor = AppColors.primary,
    this.textColor = AppColors.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconPosition iconPosition;
  final bool isLoading;
  final double borderRadius;
  final double height;
  final Color borderColor;
  final Color textColor;

  @override
  State<CustomOutlinedButton> createState() => _CustomOutlinedButtonState();
}

class _CustomOutlinedButtonState extends State<CustomOutlinedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: AnimatedOpacity(
          opacity: widget.onPressed == null && !widget.isLoading ? 0.5 : 1,
          duration: const Duration(milliseconds: 200),
          child: Container(
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: widget.borderColor,
                width: 2,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.isLoading ? null : widget.onPressed,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                splashColor: widget.borderColor.withValues(alpha: 0.2),
                highlightColor: widget.borderColor.withValues(alpha: 0.1),
                child: Center(
                  child: widget.isLoading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              widget.textColor,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.icon != null &&
                                widget.iconPosition == IconPosition.leading) ...[
                              Icon(
                                widget.icon,
                                size: 20,
                                color: widget.textColor,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              widget.label,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: widget.textColor,
                              ),
                            ),
                            if (widget.icon != null &&
                                widget.iconPosition == IconPosition.trailing) ...[
                              const SizedBox(width: 8),
                              Icon(
                                widget.icon,
                                size: 20,
                                color: widget.textColor,
                              ),
                            ],
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
