import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

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

enum IconPosition { leading, trailing }

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
