import 'dart:ui';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

/// A glassmorphism card with backdrop blur and frosted-glass border.
///
/// Best used over colorful gradient backgrounds (e.g. onboarding slides).
///
/// ```dart
/// GlassCard(
///   child: Text('Hello'),
/// )
/// ```
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.blur = 16.0,
    this.opacity = 0.12,
    this.borderRadius,
    this.padding,
    this.borderColor,
    this.boxShadow,
  });

  final Widget child;
  final double blur;
  final double opacity;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final BoxShadow? boxShadow;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppConstants.radius2xl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.glassWhite.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: borderColor ?? AppColors.glassBorder,
              width: 1,
            ),
            boxShadow: boxShadow != null
                ? [boxShadow!]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: child,
        ),
      ),
    );
  }
}
