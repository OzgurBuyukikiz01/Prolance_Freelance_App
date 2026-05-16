import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Size options for avatar display.
enum UserAvatarSize {
  small(32),
  medium(48),
  large(64),
  xlarge(96);

  const UserAvatarSize(this.value);
  final double value;
}

/// A circular avatar with optional online indicator, size options, and border.
/// Uses CachedNetworkImage with placeholder.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.imageUrl,
    this.size = UserAvatarSize.medium,
    this.showOnlineIndicator = false,
    this.isOnline = false,
    this.borderWidth = 0,
    this.borderColor = AppColors.primary,
  });

  final String imageUrl;
  final UserAvatarSize size;
  final bool showOnlineIndicator;
  final bool isOnline;
  final double borderWidth;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final sizeValue = size.value;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: sizeValue + (borderWidth * 2),
          height: sizeValue + (borderWidth * 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: borderWidth > 0
                ? Border.all(
                    color: borderColor,
                    width: borderWidth,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: AppColors.grey400.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              width: sizeValue,
              height: sizeValue,
              placeholder: (context, url) => Container(
                color: AppColors.grey200,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.grey300,
                child: Icon(
                  Icons.person,
                  size: sizeValue * 0.5,
                  color: AppColors.grey600,
                ),
              ),
            ),
          ),
        ),
        if (showOnlineIndicator)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: sizeValue * 0.3,
              height: sizeValue * 0.3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOnline ? AppColors.success : AppColors.grey500,
                border: Border.all(
                  color: AppColors.white,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
