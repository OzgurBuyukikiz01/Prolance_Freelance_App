import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Lightweight entrance animation for premium feel (Phase 7 UX).
class ProlancePressable extends StatelessWidget {
  const ProlancePressable({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child
        .animate()
        .fadeIn(duration: 320.ms, curve: Curves.easeOutCubic)
        .slideY(begin: 0.04, end: 0, duration: 320.ms, curve: Curves.easeOutCubic);
  }
}
