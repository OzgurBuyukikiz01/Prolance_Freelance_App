import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/repositories/message_repository.dart';
import '../../../core/navigation/main_nav_controller.dart';
import '../../jobs/screens/jobs_screen.dart';
import '../../messages/screens/messages_screen.dart';
import '../../post_job/screens/post_job_screen.dart';
import '../../profile/screens/profile_screen.dart';
import 'home_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final unreadTotal = context.select<MessageRepository, int>(
      (r) => r.totalUnreadCount,
    );

    return Consumer<MainNavController>(
      builder: (context, nav, _) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: IndexedStack(
            index: nav.tabIndex,
            children: [
              HomeScreen(
                onSeeAllRecommended: () =>
                    nav.openJobsFromHome(JobsSeeAllMode.recommended),
                onSeeAllRecent: () =>
                    nav.openJobsFromHome(JobsSeeAllMode.recent),
              ),
              const JobsScreen(),
              const MessagesScreen(),
              const ProfileScreen(),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context)
                      .colorScheme
                      .shadow
                      .withValues(alpha: 0.14),
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
                      isSelected: nav.tabIndex == 0,
                      onTap: () => nav.selectTab(0),
                    ),
                    _NavItem(
                      icon: Iconsax.briefcase,
                      label: 'Jobs',
                      isSelected: nav.tabIndex == 1,
                      onTap: () => nav.selectTab(1),
                    ),
                    _PostButton(
                      onTap: () async {
                        final posted = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PostJobScreen(),
                          ),
                        );
                        if (posted == true && context.mounted) {
                          nav.selectTab(0);
                        }
                      },
                    ),
                    _NavItem(
                      icon: Iconsax.message,
                      label: 'Messages',
                      isSelected: nav.tabIndex == 2,
                      onTap: () => nav.selectTab(2),
                      badgeCount: unreadTotal,
                    ),
                    _NavItem(
                      icon: Iconsax.user,
                      label: 'Profile',
                      isSelected: nav.tabIndex == 3,
                      onTap: () => nav.selectTab(3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
    final scheme = Theme.of(context).colorScheme;
    Widget iconWidget = Icon(
      icon,
      size: 24,
      color: isSelected ? AppColors.primary : scheme.onSurfaceVariant,
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
                color: isSelected ? AppColors.primary : scheme.onSurfaceVariant,
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
    final scheme = Theme.of(context).colorScheme;
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
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
