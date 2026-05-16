import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../constants/app_constants.dart';
import '../models/feed_notification_item.dart';
import '../repositories/notification_repository.dart';

/// Wraps [child] and automatically shows a top-slide banner whenever the
/// [NotificationRepository] emits a new realtime notification.
///
/// Place this high in the widget tree (e.g. inside MainNavigationScreen) so
/// the banner appears over all screens.
class NotificationToastHost extends StatefulWidget {
  const NotificationToastHost({super.key, required this.child});

  final Widget child;

  @override
  State<NotificationToastHost> createState() => _NotificationToastHostState();
}

class _NotificationToastHostState extends State<NotificationToastHost>
    with TickerProviderStateMixin {
  StreamSubscription<FeedNotificationItem>? _sub;
  OverlayEntry? _overlayEntry;
  Timer? _dismissTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sub?.cancel();
    final repo = context.read<NotificationRepository>();
    _sub = repo.newItems.listen(_showToast);
  }

  void _showToast(FeedNotificationItem item) {
    _dismissTimer?.cancel();
    _overlayEntry?.remove();
    _overlayEntry = null;

    final overlay = Overlay.of(context, rootOverlay: true);
    _overlayEntry = OverlayEntry(
      builder: (ctx) => _NotificationBanner(
        item: item,
        onTap: () {
          _dismissEntry();
          context.push('/notifications');
        },
        onDismiss: _dismissEntry,
      ),
    );
    overlay.insert(_overlayEntry!);
    _dismissTimer = Timer(const Duration(seconds: 4), _dismissEntry);
  }

  void _dismissEntry() {
    _dismissTimer?.cancel();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _sub?.cancel();
    _dismissTimer?.cancel();
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// ---------------------------------------------------------------------------

class _NotificationBanner extends StatefulWidget {
  const _NotificationBanner({
    required this.item,
    required this.onTap,
    required this.onDismiss,
  });

  final FeedNotificationItem item;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  State<_NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<_NotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  IconData _icon(FeedNotificationType type) {
    switch (type) {
      case FeedNotificationType.job:
        return Iconsax.briefcase;
      case FeedNotificationType.message:
        return Iconsax.message;
      case FeedNotificationType.proposal:
        return Iconsax.document_text;
      case FeedNotificationType.system:
        return Iconsax.info_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final safePad = MediaQuery.of(context).padding.top;

    return Positioned(
      top: safePad + 8,
      left: 16,
      right: 16,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMd,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                  border: Border.all(
                    color: scheme.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _icon(widget.item.type),
                        size: 20,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.item.title,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.item.description.isNotEmpty)
                            Text(
                              widget.item.description,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: scheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Iconsax.close_circle,
                        size: 20,
                        color: scheme.onSurfaceVariant,
                      ),
                      onPressed: widget.onDismiss,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
