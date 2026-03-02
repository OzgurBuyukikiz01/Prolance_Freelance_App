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
  static const Color _primary = Color(0xFF6C63FF);
  static const Color _background = Color(0xFFF8F9FE);

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
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: TextButton(
                    onPressed: _skipToLogin,
                    child: Text(
                      'Skip',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // PageView
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
            // Page indicator and button
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: _primary,
                      dotColor: _primary.withValues(alpha: 0.2),
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
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
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

  static const Color _primary = Color(0xFF6C63FF);

  @override
  Widget build(BuildContext context) {
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
                    _primary.withValues(alpha: 0.15),
                    _primary.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: _primary.withValues(alpha: 0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                page.icon,
                size: 72,
                color: _primary,
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
                color: const Color(0xFF2D3142),
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
                color: const Color(0xFF6B7280),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
