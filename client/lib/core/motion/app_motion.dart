import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Centralized animation durations, curves and flutter_animate effect presets.
class AppMotion {
  AppMotion._();

  // ============ Durations ============
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast    = Duration(milliseconds: 200);
  static const Duration normal  = Duration(milliseconds: 300);
  static const Duration slow    = Duration(milliseconds: 500);
  static const Duration slower  = Duration(milliseconds: 800);

  // ============ Curves (Curve objects are not const in Dart) ============
  static final Curve smooth     = Curves.easeInOutCubic;
  static final Curve springy    = Curves.elasticOut;
  static final Curve snappy     = Curves.fastOutSlowIn;
  static final Curve decelerate = Curves.decelerate;
  static final Curve bounce     = Curves.bounceOut;

  // ============ flutter_animate Presets ============

  /// Fade in while sliding up from below.
  static List<Effect> fadeSlideUp({Duration? delay, Duration? duration}) => [
    FadeEffect(
      delay: delay ?? Duration.zero,
      duration: duration ?? normal,
    ),
    SlideEffect(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
      delay: delay ?? Duration.zero,
      duration: duration ?? normal,
      curve: snappy,
    ),
  ];

  /// Scale + fade pop-in with springy feel.
  static List<Effect> popIn({Duration? delay, Duration? duration}) => [
    ScaleEffect(
      begin: const Offset(0.75, 0.75),
      end: const Offset(1.0, 1.0),
      delay: delay ?? Duration.zero,
      duration: duration ?? slow,
      curve: springy,
    ),
    FadeEffect(
      delay: delay ?? Duration.zero,
      duration: duration ?? fast,
    ),
  ];

  /// Staggered fade+slide for list items — pass the item [index].
  static List<Effect> staggeredFadeIn(int index, {Duration? itemDelay}) => [
    FadeEffect(
      delay: (itemDelay ?? const Duration(milliseconds: 80)) * index,
      duration: normal,
    ),
    SlideEffect(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
      delay: (itemDelay ?? const Duration(milliseconds: 80)) * index,
      duration: normal,
      curve: snappy,
    ),
  ];

  /// Slide in from the left.
  static List<Effect> slideInLeft({Duration? delay}) => [
    FadeEffect(delay: delay ?? Duration.zero, duration: fast),
    SlideEffect(
      begin: const Offset(-0.3, 0),
      end: Offset.zero,
      delay: delay ?? Duration.zero,
      duration: normal,
      curve: snappy,
    ),
  ];

  /// Shimmer loading placeholder.
  static List<Effect> shimmer({Duration? delay}) => [
    ShimmerEffect(
      delay: delay ?? Duration.zero,
      duration: slower,
    ),
  ];
}
