import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/repositories/message_repository.dart';
import '../../../core/navigation/main_nav_controller.dart';
import '../../../core/widgets/notification_toast.dart';
import '../../jobs/screens/jobs_screen.dart';
import '../../messages/screens/messages_screen.dart';
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
        return NotificationToastHost(
          child: Scaffold(
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
          bottomNavigationBar: _FloatingBottomNav(
            currentIndex: nav.tabIndex,
            unreadCount: unreadTotal,
            onPostTap: () async {
              final posted = await context.push<bool>('/post-job');
              if (posted == true && context.mounted) {
                nav.selectTab(0);
              }
            },
            onTabTap: nav.selectTab,
          ),
        ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Redesigned bottom nav with animated pill indicator
// ---------------------------------------------------------------------------
class _FloatingBottomNav extends StatelessWidget {
  const _FloatingBottomNav({
    required this.currentIndex,
    required this.unreadCount,
    required this.onPostTap,
    required this.onTabTap,
  });

  final int currentIndex;
  final int unreadCount;
  final VoidCallback onPostTap;
  final void Function(int) onTabTap;

  static const _items = [
    (icon: Iconsax.home_2, activeIcon: Iconsax.home_25, label: 'Ana Sayfa'),
    (icon: Iconsax.briefcase, activeIcon: Iconsax.briefcase5, label: 'İlanlar'),
    (icon: Iconsax.message, activeIcon: Iconsax.message5, label: 'Mesajlar'),
    (icon: Iconsax.user, activeIcon: Iconsax.profile_circle, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: isDark ? 0.4 : 0.1),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              // Left 2 tabs
              ..._items.sublist(0, 2).asMap().entries.map((e) {
                return Expanded(
                  child: _NavTab(
                    icon: e.value.icon,
                    activeIcon: e.value.activeIcon,
                    label: e.value.label,
                    isSelected: currentIndex == e.key,
                    onTap: () => onTabTap(e.key),
                  ),
                );
              }),

              // Center FAB
              _PostFab(onTap: onPostTap),

              // Right 2 tabs (indexes 2 & 3)
              ..._items.sublist(2).asMap().entries.map((e) {
                final tabIndex = e.key + 2;
                final isMessages = tabIndex == 2;
                return Expanded(
                  child: _NavTab(
                    icon: e.value.icon,
                    activeIcon: e.value.activeIcon,
                    label: e.value.label,
                    isSelected: currentIndex == tabIndex,
                    onTap: () => onTabTap(tabIndex),
                    badge: isMessages && unreadCount > 0
                        ? unreadCount
                        : null,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Widget iconWidget = AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, anim) => ScaleTransition(
        scale: anim,
        child: child,
      ),
      child: Icon(
        isSelected ? activeIcon : icon,
        key: ValueKey(isSelected),
        size: 22,
        color: isSelected ? AppColors.primary : scheme.onSurfaceVariant,
      ),
    );

    if (badge != null) {
      iconWidget = badges.Badge(
        badgeContent: Text(
          badge! > 99 ? '99+' : badge.toString(),
          style: GoogleFonts.poppins(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        badgeStyle: const badges.BadgeStyle(
          badgeColor: AppColors.error,
          padding: EdgeInsets.all(4),
        ),
        badgeAnimation: const badges.BadgeAnimation.scale(
          animationDuration: Duration(milliseconds: 200),
        ),
        child: iconWidget,
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      splashColor: AppColors.primary.withValues(alpha: 0.08),
      highlightColor: AppColors.primary.withValues(alpha: 0.04),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: iconWidget,
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : scheme.onSurfaceVariant,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
class _PostFab extends StatefulWidget {
  const _PostFab({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_PostFab> createState() => _PostFabState();
}

class _PostFabState extends State<_PostFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.06,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.translate(
            offset: const Offset(0, -14),
            child: GestureDetector(
              onTapDown: (_) => _ctrl.forward(),
              onTapUp: (_) {
                _ctrl.reverse();
                widget.onTap();
              },
              onTapCancel: () => _ctrl.reverse(),
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 - _ctrl.value,
                    child: child,
                  );
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.45),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Iconsax.add_circle,
                    size: 26,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          )
              .animate()
              .scale(
                begin: const Offset(0.6, 0.6),
                duration: 500.ms,
                curve: Curves.elasticOut,
                delay: 200.ms,
              )
              .fadeIn(delay: 150.ms),
          const SizedBox(height: 2),
          Text(
            'Yayınla',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
