import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/constants/app_colors.dart';
import '../../jobs/screens/jobs_screen.dart';
import '../../messages/screens/messages_screen.dart';
import '../../post_job/screens/post_job_screen.dart';
import '../../profile/screens/profile_screen.dart';
import 'home_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const JobsScreen(),
    const PostJobScreen(),
    const MessagesScreen(),
    const ProfileScreen(),
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.grey400.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Iconsax.home_2,
                  label: 'Home',
                  isSelected: _currentIndex == 0,
                  onTap: () => _onPageChanged(0),
                ),
                _NavItem(
                  icon: Iconsax.briefcase,
                  label: 'Jobs',
                  isSelected: _currentIndex == 1,
                  onTap: () => _onPageChanged(1),
                ),
                _PostButton(
                  onTap: () => _onPageChanged(2),
                ),
                _NavItem(
                  icon: Iconsax.message,
                  label: 'Messages',
                  isSelected: _currentIndex == 3,
                  onTap: () => _onPageChanged(3),
                  badgeCount: 3,
                ),
                _NavItem(
                  icon: Iconsax.user,
                  label: 'Profile',
                  isSelected: _currentIndex == 4,
                  onTap: () => _onPageChanged(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = Icon(
      icon,
      size: 24,
      color: isSelected ? AppColors.primary : AppColors.textSecondary,
    );

    if (badgeCount > 0) {
      iconWidget = badges.Badge(
        badgeContent: Text(
          badgeCount > 99 ? '99+' : badgeCount.toString(),
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
        badgeStyle: _badgeStyle,
        badgeAnimation: _badgeAnimation,
        child: iconWidget,
      );
    }

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final _badgeStyle = badges.BadgeStyle(
  badgeColor: AppColors.error,
  padding: const EdgeInsets.all(4),
);

final _badgeAnimation = badges.BadgeAnimation.scale(
  animationDuration: const Duration(milliseconds: 200),
  colorChangeAnimationDuration: Duration.zero,
);

class _PostButton extends StatelessWidget {
  const _PostButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.translate(
            offset: const Offset(0, -16),
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Iconsax.add_circle,
                  size: 28,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Post',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
