import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/feed_notification_item.dart';
import '../../../core/repositories/notification_repository.dart';
import '../../../core/widgets/prolance_empty_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _markAllAsRead() {
    context.read<NotificationRepository>().markAllRead();
  }

  IconData _getIconForType(FeedNotificationType type) {
    switch (type) {
      case FeedNotificationType.job:
        return Iconsax.briefcase;
      case FeedNotificationType.message:
        return Iconsax.message;
      case FeedNotificationType.system:
        return Iconsax.info_circle;
      case FeedNotificationType.proposal:
        return Iconsax.document_text;
    }
  }

  List<FeedNotificationItem> _getNotificationsForTab(
    int index,
    List<FeedNotificationItem> all,
    List<FeedNotificationItem> jobTab,
    List<FeedNotificationItem> messageTab,
    List<FeedNotificationItem> systemTab,
  ) {
    switch (index) {
      case 0:
        return all;
      case 1:
        return jobTab;
      case 2:
        return messageTab;
      case 3:
        return systemTab;
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final feed = context.watch<NotificationRepository>().items;
    final jobTab = feed
        .where(
          (n) =>
              n.type == FeedNotificationType.job ||
              n.type == FeedNotificationType.proposal,
        )
        .toList();
    final messageTab =
        feed.where((n) => n.type == FeedNotificationType.message).toList();
    final systemTab =
        feed.where((n) => n.type == FeedNotificationType.system).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: Text(
              'Mark all as read',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          indicatorColor: AppColors.primary,
          labelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 14),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Jobs'),
            Tab(text: 'Messages'),
            Tab(text: 'System'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(4, (index) {
          final notifications = _getNotificationsForTab(
            index,
            feed,
            jobTab,
            messageTab,
            systemTab,
          );
          if (notifications.isEmpty) {
            return _buildEmptyState();
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMd,
              vertical: AppConstants.paddingSm,
            ),
            itemCount: notifications.length,
            itemBuilder: (context, i) {
              final item = notifications[i];
              return FadeInUp(
                duration: const Duration(milliseconds: 400),
                delay: Duration(milliseconds: 50 * i),
                child: Dismissible(
                  key: Key(item.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: AppColors.error,
                    child: const Icon(Iconsax.trash, color: AppColors.white, size: 24),
                  ),
                  onDismissed: (_) => context
                      .read<NotificationRepository>()
                      .removeLocal(item.id),
                  child: _buildNotificationItem(item),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildNotificationItem(FeedNotificationItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingSm),
      decoration: BoxDecoration(
        color: item.isRead
            ? Theme.of(context).colorScheme.surfaceContainerHigh
            : AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: item.isRead
            ? null
            : Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 1,
              ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMd,
          vertical: AppConstants.paddingSm,
        ),
        leading: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              ),
              child: Icon(
                _getIconForType(item.type),
                color: AppColors.primary,
                size: 24,
              ),
            ),
            if (!item.isRead)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          item.title,
          style: AppTextStyles.heading6.copyWith(
            fontWeight: item.isRead ? FontWeight.w500 : FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              item.description,
              style: AppTextStyles.bodySmallSecondary.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              timeago.format(item.createdAt),
              style: AppTextStyles.caption.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildEmptyState() => ProlanceEmptyState.notifications();
}
