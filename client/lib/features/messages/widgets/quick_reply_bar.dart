import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';

/// Horizontal scrollable row of quick-reply suggestion chips.
class QuickReplyBar extends StatelessWidget {
  const QuickReplyBar({super.key, required this.onSelect});

  final void Function(String text) onSelect;

  static const _replies = [
    'Merhaba! Teklifiniz için teşekkürler.',
    'Daha fazla bilgi alabilir miyim?',
    'Ödeme escrow\'a yatırıldı.',
    'Projeyi teslim ettim.',
    'Ne zaman başlayabiliriz?',
    'Fiyat konusunda görüşebilir miyiz?',
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.surfaceContainerLow,
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 4, top: 6),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _replies.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final reply = _replies[index];
            return InkWell(
              onTap: () => onSelect(reply),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  reply,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
