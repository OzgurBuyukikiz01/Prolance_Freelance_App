import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

/// A consistent empty state widget used across all list screens.
///
/// Shows a large icon, a title, a subtitle, and an optional action button.
class ProlanceEmptyState extends StatelessWidget {
  const ProlanceEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  // ── Convenience constructors ──────────────────────────────────────────────

  factory ProlanceEmptyState.favorites({VoidCallback? onBrowse}) =>
      ProlanceEmptyState(
        icon: Iconsax.heart,
        title: 'No saved listings yet',
        subtitle: 'Save listings you like\nand find them here anytime.',
        actionLabel: 'Browse listings',
        onAction: onBrowse,
      );

  factory ProlanceEmptyState.messages() => const ProlanceEmptyState(
        icon: Iconsax.message,
        title: 'No messages yet',
        subtitle: 'Send a proposal or message\na client to start chatting.',
      );

  factory ProlanceEmptyState.proposals() => const ProlanceEmptyState(
        icon: Iconsax.document_text,
        title: 'No proposals sent yet',
        subtitle: 'Submit proposals on matching projects\nand track them here.',
      );

  factory ProlanceEmptyState.notifications() => const ProlanceEmptyState(
        icon: Iconsax.notification,
        title: 'No notifications',
        subtitle: 'New alerts will appear here.',
      );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: scheme.primary,
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.7, 0.7),
                  duration: 500.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 300.ms),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            )
                .animate()
                .fadeIn(delay: 100.ms, duration: 400.ms)
                .slideY(begin: 0.3, end: 0, duration: 400.ms),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: scheme.onSurfaceVariant,
                height: 1.5,
              ),
            )
                .animate()
                .fadeIn(delay: 150.ms, duration: 400.ms),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Iconsax.arrow_right_3, size: 18),
                label: Text(
                  actionLabel!,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              )
                  .animate()
                  .fadeIn(delay: 250.ms, duration: 400.ms)
                  .slideY(begin: 0.5, end: 0, duration: 400.ms),
            ],
          ],
        ),
      ),
    );
  }
}
