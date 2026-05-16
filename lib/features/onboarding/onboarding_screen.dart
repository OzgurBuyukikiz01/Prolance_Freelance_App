import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Iconsax.search_normal_1,
      title: 'Find Top Talent',
      description:
          'Discover skilled freelancers from around the world. Browse profiles, check ratings, and find the perfect match for your project.',
    ),
    OnboardingPage(
      icon: Iconsax.document_upload,
      title: 'Post Your Project',
      description:
          'Share your project details in minutes. Our simple process makes it easy to get quotes and start working with talented professionals.',
    ),
    OnboardingPage(
      icon: Iconsax.chart_2,
      title: 'Grow Together',
      description:
          'Build lasting partnerships and watch your business thrive. Collaborate, communicate, and achieve your goals together.',
    ),
  ];

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _previousPage() {
    if (_currentPage <= 0) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _skipToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    IconButton(
                      tooltip: 'Previous',
                      onPressed: _previousPage,
                      icon: Icon(
                        Iconsax.arrow_left_2,
                        color: scheme.onSurface,
                        size: 26,
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                  const Spacer(),
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: TextButton(
                      onPressed: _skipToLogin,
                      child: Text(
                        'Skip',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (_currentPage < _pages.length - 1)
                    IconButton(
                      tooltip: 'Next',
                      onPressed: _nextPage,
                      icon: Icon(
                        Iconsax.arrow_right_3,
                        color: scheme.onSurface,
                        size: 26,
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPageContent(
                    page: _pages[index],
                    pageIndex: index,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: scheme.primary,
                      dotColor: scheme.brightness == Brightness.dark
                          ? scheme.primary.withValues(alpha: 0.35)
                          : scheme.primary.withValues(alpha: 0.2),
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 4,
                      spacing: 8,
                    ),
                  ),
                  const SizedBox(height: 32),
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: scheme.primary,
                          foregroundColor: scheme.onPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          _currentPage == _pages.length - 1
                              ? 'Get Started'
                              : 'Next',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _OnboardingPageContent extends StatelessWidget {
  final OnboardingPage page;
  final int pageIndex;

  const _OnboardingPageContent({
    required this.page,
    required this.pageIndex,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final primary = scheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInUp(
            duration: const Duration(milliseconds: 700),
            delay: Duration(milliseconds: 100 * pageIndex),
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primary.withValues(alpha: 0.22),
                    primary.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                page.icon,
                size: 72,
                color: primary,
              ),
            ),
          ),
          const SizedBox(height: 48),
          FadeInUp(
            duration: const Duration(milliseconds: 700),
            delay: Duration(milliseconds: 200 + (100 * pageIndex)),
            child: Text(
              page.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            duration: const Duration(milliseconds: 700),
            delay: Duration(milliseconds: 300 + (100 * pageIndex)),
            child: Text(
              page.description,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: scheme.onSurfaceVariant,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
