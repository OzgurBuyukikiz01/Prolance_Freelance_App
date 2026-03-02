import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';

enum NotificationType { job, message, system, proposal }

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final NotificationType type;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.type,
    this.isRead = false,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<NotificationItem> _allNotifications;
  late List<NotificationItem> _jobNotifications;
  late List<NotificationItem> _messageNotifications;
  late List<NotificationItem> _systemNotifications;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initDummyData();
  }

  void _initDummyData() {
    final now = DateTime.now();
    _allNotifications = [
      NotificationItem(
        id: '1',
        title: 'New proposal received',
        description: 'John Doe submitted a proposal for your Flutter Developer job.',
        createdAt: now.subtract(const Duration(minutes: 5)),
        type: NotificationType.proposal,
        isRead: false,
      ),
      NotificationItem(
        id: '2',
        title: 'Job posted successfully',
        description: 'Your "Mobile App Development" job is now live and visible to freelancers.',
        createdAt: now.subtract(const Duration(hours: 1)),
        type: NotificationType.job,
        isRead: false,
      ),
      NotificationItem(
        id: '3',
        title: 'New message from Sarah',
        description: 'Hi! I have a question about the project requirements...',
        createdAt: now.subtract(const Duration(hours: 2)),
        type: NotificationType.message,
        isRead: false,
      ),
      NotificationItem(
        id: '4',
        title: 'Profile verification complete',
        description: 'Your identity has been verified. You now have a verified badge.',
        createdAt: now.subtract(const Duration(hours: 5)),
        type: NotificationType.system,
        isRead: true,
      ),
      NotificationItem(
        id: '5',
        title: 'Job application viewed',
        description: 'Your application for "UI/UX Designer" was viewed by the client.',
        createdAt: now.subtract(const Duration(days: 1)),
        type: NotificationType.job,
        isRead: true,
      ),
      NotificationItem(
        id: '6',
        title: 'Chat request',
        description: 'Alex wants to start a conversation about your proposal.',
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
        type: NotificationType.message,
        isRead: false,
      ),
      NotificationItem(
        id: '7',
        title: 'Payment received',
        description: '\$250 has been added to your Prolance balance.',
        createdAt: now.subtract(const Duration(days: 2)),
        type: NotificationType.system,
        isRead: true,
      ),
      NotificationItem(
        id: '8',
        title: 'Proposal accepted',
        description: 'Congratulations! Your proposal for "E-commerce Website" was accepted.',
        createdAt: now.subtract(const Duration(days: 2, hours: 5)),
        type: NotificationType.proposal,
        isRead: false,
      ),
      NotificationItem(
        id: '9',
        title: 'New job match',
        description: 'A new Web Dev job matches your skills: "React Developer needed".',
        createdAt: now.subtract(const Duration(days: 3)),
        type: NotificationType.job,
        isRead: true,
      ),
      NotificationItem(
        id: '10',
        title: 'System maintenance',
        description: 'Scheduled maintenance on March 5, 2:00 AM - 4:00 AM UTC.',
        createdAt: now.subtract(const Duration(days: 4)),
        type: NotificationType.system,
        isRead: true,
      ),
    ];
    _jobNotifications = _allNotifications
        .where((n) =>
            n.type == NotificationType.job || n.type == NotificationType.proposal)
        .toList();
    _messageNotifications = _allNotifications
        .where((n) => n.type == NotificationType.message)
        .toList();
    _systemNotifications = _allNotifications
        .where((n) => n.type == NotificationType.system)
        .toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _markAllAsRead() {
    setState(() {
      _allNotifications = _allNotifications
          .map((n) => NotificationItem(
                id: n.id,
                title: n.title,
                description: n.description,
                createdAt: n.createdAt,
                type: n.type,
                isRead: true,
              ))
          .toList();
      _jobNotifications = _jobNotifications
          .map((n) => NotificationItem(
                id: n.id,
                title: n.title,
                description: n.description,
                createdAt: n.createdAt,
                type: n.type,
                isRead: true,
              ))
          .toList();
      _messageNotifications = _messageNotifications
          .map((n) => NotificationItem(
                id: n.id,
                title: n.title,
                description: n.description,
                createdAt: n.createdAt,
                type: n.type,
                isRead: true,
              ))
          .toList();
      _systemNotifications = _systemNotifications
          .map((n) => NotificationItem(
                id: n.id,
                title: n.title,
                description: n.description,
                createdAt: n.createdAt,
                type: n.type,
                isRead: true,
              ))
          .toList();
    });
  }

  void _removeNotification(String id) {
    setState(() {
      _allNotifications.removeWhere((n) => n.id == id);
      _jobNotifications.removeWhere((n) => n.id == id);
      _messageNotifications.removeWhere((n) => n.id == id);
      _systemNotifications.removeWhere((n) => n.id == id);
    });
  }

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.job:
        return Iconsax.briefcase;
      case NotificationType.message:
        return Iconsax.message;
      case NotificationType.system:
        return Iconsax.info_circle;
      case NotificationType.proposal:
        return Iconsax.document_text;
    }
  }

  List<NotificationItem> _getNotificationsForTab(int index) {
    switch (index) {
      case 0:
        return _allNotifications;
      case 1:
        return _jobNotifications;
      case 2:
        return _messageNotifications;
      case 3:
        return _systemNotifications;
      default:
        return _allNotifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
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
          unselectedLabelColor: AppColors.textSecondary,
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
          final notifications = _getNotificationsForTab(index);
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
                  onDismissed: (_) => _removeNotification(item.id),
                  child: _buildNotificationItem(item),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingSm),
      decoration: BoxDecoration(
        color: item.isRead ? AppColors.surface : AppColors.primary.withValues(alpha: 0.08),
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
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              item.description,
              style: AppTextStyles.bodySmallSecondary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              timeago.format(item.createdAt),
              style: AppTextStyles.caption,
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.notification,
            size: 64,
            color: AppColors.grey400,
          ),
          const SizedBox(height: AppConstants.paddingLg),
          Text(
            'No notifications yet',
            style: AppTextStyles.heading6,
          ),
          const SizedBox(height: AppConstants.paddingSm),
          Text(
            'When you get notifications, they\'ll appear here',
            style: AppTextStyles.bodyMediumSecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
