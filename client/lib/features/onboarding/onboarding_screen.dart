import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/constants/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _bgController;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      icon: Iconsax.search_normal_1,
      emoji: '🔍',
      gradientColors: [Color(0xFF6C63FF), Color(0xFF8B85FF)],
      title: 'Discover top\ntalent',
      subtitle:
          'Find skilled freelancers worldwide. Browse profiles and read reviews.',
      tags: ['5,000+ freelancers', 'Instant matching', 'AI suggestions'],
    ),
    _OnboardingData(
      icon: Iconsax.document_upload,
      emoji: '🚀',
      gradientColors: [Color(0xFF00BFA6), Color(0xFF00E5CC)],
      title: 'Post your\nproject',
      subtitle:
          'Share project details in minutes. Get proposals and start working fast.',
      tags: ['Quick posting', 'Smart matching', 'Free to post'],
    ),
    _OnboardingData(
      icon: Iconsax.wallet_money,
      emoji: '🔒',
      gradientColors: [Color(0xFF7C3AED), Color(0xFF9D5CF0)],
      title: 'Pay safely\nwith escrow',
      subtitle:
          'Funds are held securely until work is done. Reduce one-sided risk.',
      tags: ['Escrow protection', 'AES-256', 'Dispute support'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-0.8 + _bgController.value * 0.4, -1),
                end: Alignment(0.8 - _bgController.value * 0.4, 1),
                colors: page.gradientColors,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Top bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AnimatedOpacity(
                          opacity: _currentPage > 0 ? 1 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: GestureDetector(
                            onTap: () {
                              if (_currentPage > 0) {
                                _pageController.previousPage(
                                  duration:
                                      const Duration(milliseconds: 500),
                                  curve: Curves.easeInOutCubic,
                                );
                              }
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    Colors.white.withValues(alpha: 0.18),
                                border: Border.all(
                                  color: Colors.white
                                      .withValues(alpha: 0.35),
                                ),
                              ),
                              child: const Icon(Iconsax.arrow_left_2,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/login'),
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
                  ),

                  // PageView
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (i) =>
                          setState(() => _currentPage = i),
                      itemCount: _pages.length,
                      itemBuilder: (context, index) {
                        return _OnboardingPageContent(
                          data: _pages[index],
                          index: index,
                          isActive: index == _currentPage,
                          screenSize: size,
                        );
                      },
                    ),
                  ),

                  // Bottom section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                    child: Column(
                      children: [
                        SmoothPageIndicator(
                          controller: _pageController,
                          count: _pages.length,
                          effect: ExpandingDotsEffect(
                            activeDotColor: Colors.white,
                            dotColor:
                                Colors.white.withValues(alpha: 0.4),
                            dotHeight: 8,
                            dotWidth: 8,
                            expansionFactor: 3.5,
                            spacing: 6,
                          ),
                        ),
                        const SizedBox(height: 28),
                        _NextButton(
                          isLast: _currentPage == _pages.length - 1,
                          onTap: _next,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
class _OnboardingData {
  final IconData icon;
  final String emoji;
  final List<Color> gradientColors;
  final String title;
  final String subtitle;
  final List<String> tags;

  const _OnboardingData({
    required this.icon,
    required this.emoji,
    required this.gradientColors,
    required this.title,
    required this.subtitle,
    required this.tags,
  });
}

// ---------------------------------------------------------------------------
class _OnboardingPageContent extends StatelessWidget {
  const _OnboardingPageContent({
    required this.data,
    required this.index,
    required this.isActive,
    required this.screenSize,
  });

  final _OnboardingData data;
  final int index;
  final bool isActive;
  final Size screenSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration card
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(36),
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
                Text(data.emoji, style: const TextStyle(fontSize: 56)),
                const SizedBox(height: 4),
                Icon(data.icon,
                    size: 32,
                    color: Colors.white.withValues(alpha: 0.7)),
              ],
            ),
          )
              .animate(target: isActive ? 1 : 0)
              .scale(
                begin: const Offset(0.7, 0.7),
                end: const Offset(1.0, 1.0),
                duration: 600.ms,
                curve: Curves.elasticOut,
              )
              .fadeIn(duration: 400.ms),

          const SizedBox(height: 40),

          Text(
            data.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          )
              .animate(target: isActive ? 1 : 0)
              .fadeIn(delay: 150.ms, duration: 500.ms)
              .slideY(begin: 0.3, end: 0),

          const SizedBox(height: 14),

          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.55,
            ),
          )
              .animate(target: isActive ? 1 : 0)
              .fadeIn(delay: 250.ms, duration: 500.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 24),

          // Tags
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: data.tags.asMap().entries.map((e) {
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  e.value,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
                  .animate(target: isActive ? 1 : 0)
                  .fadeIn(
                      delay: Duration(milliseconds: 300 + e.key * 80),
                      duration: 400.ms)
                  .slideX(begin: 0.2, end: 0);
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
class _NextButton extends StatelessWidget {
  const _NextButton({required this.isLast, required this.onTap});
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 58,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isLast ? 'Get started' : 'Continue',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isLast ? Iconsax.flash_1 : Iconsax.arrow_right_3,
              color: AppColors.primary,
              size: 20,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 500.ms).slideY(begin: 0.3, end: 0);
  }
}
