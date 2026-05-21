import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:rive/rive.dart' hide LinearGradient;
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

// ─── Data model ──────────────────────────────────────────────────────────────

class _SlideData {
  const _SlideData({
    required this.gradientColors,
    required this.riveAsset,
    required this.riveAnimation,
    required this.fallbackEmoji,
    required this.fallbackIcon,
    required this.title,
    required this.subtitle,
    required this.tags,
  });

  final List<Color> gradientColors;
  final String riveAsset;
  final String riveAnimation;
  final String fallbackEmoji;
  final IconData fallbackIcon;
  final String title;
  final String subtitle;
  final List<String> tags;
}

const _slides = [
  _SlideData(
    gradientColors: [Color(0xFFFF5833), Color(0xFFFF8A65)],
    riveAsset: 'assets/rive/welcome.riv',
    riveAnimation: 'idle',
    fallbackEmoji: '👋',
    fallbackIcon: Iconsax.people,
    title: 'Welcome to\nProlance',
    subtitle:
        'The smartest way to hire top freelancers or land great projects.',
    tags: ['5,000+ freelancers', 'Verified profiles', 'Global talent'],
  ),
  _SlideData(
    gradientColors: [Color(0xFF0EBD90), Color(0xFF2DD5A8)],
    riveAsset: 'assets/rive/discover.riv',
    riveAnimation: 'idle',
    fallbackEmoji: '🔍',
    fallbackIcon: Iconsax.search_normal_1,
    title: 'Discover top\ntalent fast',
    subtitle:
        'Browse profiles, read reviews and get proposals from skilled freelancers.',
    tags: ['AI matching', 'Instant proposals', 'Skill filters'],
  ),
  _SlideData(
    gradientColors: [Color(0xFF7248FE), Color(0xFF9075FF)],
    riveAsset: 'assets/rive/post.riv',
    riveAnimation: 'idle',
    fallbackEmoji: '🚀',
    fallbackIcon: Iconsax.document_upload,
    title: 'Post your\nproject',
    subtitle:
        'Share project details in minutes. Get proposals and start working fast.',
    tags: ['Free to post', 'Smart matching', 'Quick setup'],
  ),
  _SlideData(
    gradientColors: [Color(0xFFFF5833), Color(0xFF7248FE)],
    riveAsset: 'assets/rive/shield.riv',
    riveAnimation: 'idle',
    fallbackEmoji: '🔒',
    fallbackIcon: Iconsax.shield_tick,
    title: 'Pay safely\nwith escrow',
    subtitle:
        'Funds are held securely until work is approved. Zero risk on both sides.',
    tags: ['Escrow protection', 'AES-256 encrypted', 'Dispute support'],
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _slides.length - 1) {
      _pageCtrl.nextPage(
        duration: AppConstants.animationSlow,
        curve: Curves.easeInOutCubic,
      );
    } else {
      context.go('/login');
    }
  }

  void _prev() {
    if (_page > 0) {
      _pageCtrl.previousPage(
        duration: AppConstants.animationSlow,
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_page];

    return Scaffold(
      body: Stack(
        children: [
          // ── Animated gradient background ─────────────────────────────────
          AnimatedContainer(
            duration: AppConstants.animationNormal,
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: slide.gradientColors,
              ),
            ),
            width: double.infinity,
            height: double.infinity,
          ),

          // ── Page content ─────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Top bar
                _TopBar(
                  page: _page,
                  total: _slides.length,
                  onBack: _prev,
                  onSkip: () => context.go('/login'),
                ),

                // Illustration area (top 55%)
                Expanded(
                  flex: 55,
                  child: PageView.builder(
                    controller: _pageCtrl,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemCount: _slides.length,
                    itemBuilder: (_, i) => _IllustrationPane(
                      slide: _slides[i],
                      isActive: i == _page,
                    ),
                  ),
                ),

                // White bottom card (45%)
                _BottomCard(
                  slide: slide,
                  page: _page,
                  total: _slides.length,
                  pageController: _pageCtrl,
                  onNext: _next,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Top bar ─────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.page,
    required this.total,
    required this.onBack,
    required this.onSkip,
  });

  final int page;
  final int total;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnimatedOpacity(
            opacity: page > 0 ? 1 : 0,
            duration: const Duration(milliseconds: 250),
            child: GestureDetector(
              onTap: page > 0 ? onBack : null,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                ),
                child: const Icon(
                  Iconsax.arrow_left_2,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onSkip,
            child: Text(
              'Skip',
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Illustration pane ───────────────────────────────────────────────────────

class _IllustrationPane extends StatelessWidget {
  const _IllustrationPane({required this.slide, required this.isActive});

  final _SlideData slide;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _RiveOrFallback(slide: slide, isActive: isActive),
    );
  }
}

class _RiveOrFallback extends StatefulWidget {
  const _RiveOrFallback({required this.slide, required this.isActive});

  final _SlideData slide;
  final bool isActive;

  @override
  State<_RiveOrFallback> createState() => _RiveOrFallbackState();
}

class _RiveOrFallbackState extends State<_RiveOrFallback> {
  bool _riveError = false;
  bool _assetChecked = false;
  bool _canUseRive = false;

  @override
  void initState() {
    super.initState();
    _probeRiveAsset();
  }

  Future<void> _probeRiveAsset() async {
    try {
      await rootBundle.load(widget.slide.riveAsset);
      if (!mounted) return;
      setState(() {
        _assetChecked = true;
        _canUseRive = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _assetChecked = true;
        _canUseRive = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show Rive only when the asset exists locally; otherwise use the fallback.
    final riveWidget = _assetChecked && _canUseRive && !_riveError
        ? RiveAnimation.asset(
            widget.slide.riveAsset,
            fit: BoxFit.contain,
            animations: [widget.slide.riveAnimation],
            onInit: (_) {},
          )
        : null;

    final illustration = riveWidget == null
        ? _FallbackIllustration(slide: widget.slide)
        : _RiveWrapper(
            child: riveWidget!,
            onError: () {
              if (mounted) setState(() => _riveError = true);
            },
          );

    return illustration
        .animate(target: widget.isActive ? 1 : 0)
        .scale(
          begin: const Offset(0.75, 0.75),
          end: const Offset(1.0, 1.0),
          duration: 600.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: 400.ms);
  }
}

class _RiveWrapper extends StatefulWidget {
  const _RiveWrapper({required this.child, required this.onError});

  final Widget child;
  final VoidCallback onError;

  @override
  State<_RiveWrapper> createState() => _RiveWrapperState();
}

class _RiveWrapperState extends State<_RiveWrapper> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 240,
      // Catch any RiveException by wrapping in error boundary
      child: widget.child,
    );
  }
}

class _FallbackIllustration extends StatelessWidget {
  const _FallbackIllustration({required this.slide});

  final _SlideData slide;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppConstants.radius3xl),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(slide.fallbackEmoji, style: const TextStyle(fontSize: 60)),
          const SizedBox(height: 6),
          Icon(
            slide.fallbackIcon,
            size: 32,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }
}

// ─── White bottom card ───────────────────────────────────────────────────────

class _BottomCard extends StatelessWidget {
  const _BottomCard({
    required this.slide,
    required this.page,
    required this.total,
    required this.pageController,
    required this.onNext,
  });

  final _SlideData slide;
  final int page;
  final int total;
  final PageController pageController;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
                  slide.title,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                )
                .animate(key: ValueKey('title_$page'))
                .fadeIn(duration: 350.ms)
                .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),

            const SizedBox(height: 10),

            // Subtitle
            Text(
                  slide.subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.neutral500,
                    height: 1.6,
                  ),
                )
                .animate(key: ValueKey('sub_$page'))
                .fadeIn(delay: 80.ms, duration: 350.ms),

            const SizedBox(height: 16),

            // Tags
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: slide.tags.asMap().entries.map((e) {
                return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary100,
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusFull,
                        ),
                      ),
                      child: Text(
                        e.value,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.primary700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                    .animate(key: ValueKey('tag_${page}_${e.key}'))
                    .fadeIn(
                      delay: Duration(milliseconds: 120 + e.key * 60),
                      duration: 300.ms,
                    )
                    .slideX(begin: 0.15, end: 0);
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Progress dots + Button row
            Row(
              children: [
                // Dots
                Row(
                  children: List.generate(total, (i) {
                    final active = i == page;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(right: 6),
                      width: active ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.primary500
                            : AppColors.neutral200,
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusFull,
                        ),
                      ),
                    );
                  }),
                ),

                const Spacer(),

                // Next button
                GestureDetector(
                  onTap: onNext,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 52,
                    width: page == total - 1 ? 160 : 52,
                    decoration: BoxDecoration(
                      gradient: AppColors.coralGradient,
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusFull,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary500.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: page == total - 1
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Get started',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Iconsax.flash_1,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
                            )
                          : const Icon(
                              Iconsax.arrow_right_3,
                              color: Colors.white,
                              size: 22,
                            ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
