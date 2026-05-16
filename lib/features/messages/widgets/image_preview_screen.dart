import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:share_plus/share_plus.dart';

/// Full-screen image viewer with Hero animation, pinch-to-zoom, and share.
class ImagePreviewScreen extends StatelessWidget {
  const ImagePreviewScreen({
    super.key,
    required this.imageUrl,
    required this.heroTag,
  });

  final String imageUrl;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Iconsax.close_circle, color: Colors.white, size: 28),
        ),
        actions: [
          IconButton(
            onPressed: () => Share.share(imageUrl, subject: 'Paylaşılan Görsel'),
            icon: const Icon(Iconsax.share, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Hero(
          tag: heroTag,
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.contain,
              placeholder: (_, _) => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              errorWidget: (_, _, _) => const Icon(
                Iconsax.image,
                color: Colors.white54,
                size: 60,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
