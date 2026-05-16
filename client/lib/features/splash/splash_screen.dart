import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/state/app_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bgController;
  late final AnimationController _pulseController;

  static const Color _p1 = Color(0xFF6C63FF);
  static const Color _p2 = Color(0xFF4F46E5);
  static const Color _p3 = Color(0xFF7C3AED);

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _navigateNext();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Duration get _splashDelay {
    final isTest = WidgetsBinding.instance.runtimeType
        .toString()
        .contains('AutomatedTest');
    return isTest ? Duration.zero : const Duration(seconds: 3);
  }

  Future<void> _navigateNext() async {
    await Future.delayed(_splashDelay);
    if (!mounted) return;
    final appState = context.read<AppState>();
    while (!appState.isReady) {
      await Future.delayed(const Duration(milliseconds: 150));
      if (!mounted) return;
    }
    if (appState.isLoggedIn) {
      if (!mounted) return;
      context.go('/home');
    } else {
      if (!mounted) return;
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(
                  -1.0 + _bgController.value * 0.4,
                  -1.0 + _bgController.value * 0.3,
                ),
                end: Alignment(
                  1.0 - _bgController.value * 0.3,
                  1.0 - _bgController.value * 0.2,
                ),
                colors: const [_p1, _p2, _p3],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: child,
          );
        },
        child: Stack(
          children: [
            // Floating orbs
            _FloatingOrb(
              top: -80,
              left: -60,
              size: 280,
              opacity: 0.15,
              controller: _bgController,
            ),
            _FloatingOrb(
              top: null,
              bottom: -100,
              right: -80,
              size: 320,
              opacity: 0.12,
              controller: _bgController,
              phase: 0.5,
            ),
            _FloatingOrb(
              top: 200,
              right: -40,
              size: 160,
              opacity: 0.1,
              controller: _bgController,
              phase: 0.25,
            ),

            // Main content
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo container with pulse ring
                    _PulseLogo(pulseController: _pulseController),

                    const SizedBox(height: 36),

                    // App name
                    Text(
                      'Prolance',
                      style: GoogleFonts.poppins(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -1,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 600.ms)
                        .slideY(begin: 0.3, end: 0),

                    const SizedBox(height: 8),

                    Text(
                      'Freelance Your Way',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.85),
                        letterSpacing: 1.5,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 500.ms, duration: 600.ms)
                        .slideY(begin: 0.3, end: 0),

                    const SizedBox(height: 64),

                    // Trust tags
                    _TrustTags()
                        .animate()
                        .fadeIn(delay: 800.ms, duration: 600.ms),
                  ],
                ),
              ),
            ),

            // Bottom loading bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _AnimatedLoadingBar()
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 400.ms),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
class _PulseLogo extends StatelessWidget {
  const _PulseLogo({required this.pulseController});
  final AnimationController pulseController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, child) {
        final pulse = pulseController.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulse ring
            Container(
              width: 140 + pulse * 20,
              height: 140 + pulse * 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12 * (1 - pulse)),
                  width: 2,
                ),
              ),
            ),
            // Middle ring
            Container(
              width: 130 + pulse * 10,
              height: 130 + pulse * 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2 * (1 - pulse)),
                  width: 1.5,
                ),
              ),
            ),
            // Logo circle
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.15),
                    blurRadius: 20,
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'P',
                  style: GoogleFonts.poppins(
                    fontSize: 52,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    )
        .animate()
        .scale(begin: const Offset(0.4, 0.4), duration: 700.ms, curve: Curves.elasticOut)
        .fadeIn(duration: 400.ms);
  }
}

// ---------------------------------------------------------------------------
class _FloatingOrb extends StatelessWidget {
  const _FloatingOrb({
    required this.size,
    required this.opacity,
    required this.controller,
    this.top,
    this.left,
    this.right,
    this.bottom,
    this.phase = 0.0,
  });

  final double size;
  final double opacity;
  final AnimationController controller;
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
  final double phase;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = (controller.value + phase) % 1.0;
        final dy = math.sin(t * math.pi * 2) * 20;
        return Positioned(
          top: top != null ? top! + dy : null,
          left: left,
          right: right,
          bottom: bottom != null ? bottom! - dy : null,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: opacity),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
class _TrustTags extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tags = [
      ('🔒', 'Escrow Safe'),
      ('⚡', 'Realtime'),
      ('🌐', 'Global'),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: tags.map((t) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t.$1, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 5),
              Text(
                t.$2,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
class _AnimatedLoadingBar extends StatefulWidget {
  @override
  State<_AnimatedLoadingBar> createState() => _AnimatedLoadingBarState();
}

class _AnimatedLoadingBarState extends State<_AnimatedLoadingBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      color: Colors.white.withValues(alpha: 0.1),
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, _) {
          return FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _anim.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.0),
                    Colors.white.withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
