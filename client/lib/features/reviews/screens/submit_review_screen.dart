import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/job_model.dart';
import '../../../core/repositories/review_repository.dart';
import '../../../core/state/app_state.dart';
import '../../../core/widgets/overlays/prolance_messenger.dart';

class SubmitReviewScreen extends StatefulWidget {
  const SubmitReviewScreen({
    super.key,
    required this.job,
    required this.revieweeId,
    required this.revieweeName,
    this.revieweeAvatar = '',
  });

  final JobModel job;
  final String revieweeId;
  final String revieweeName;
  final String revieweeAvatar;

  @override
  State<SubmitReviewScreen> createState() => _SubmitReviewScreenState();
}

class _SubmitReviewScreenState extends State<SubmitReviewScreen> {
  final _commentController = TextEditingController();
  double _rating = 5.0;
  bool _isLoading = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      ProlanceMessenger.error(
        context,
        context.read<AppState>().t('Please write a review.', 'Lütfen bir yorum yazın.'),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await context.read<ReviewRepository>().submitReview(
            jobId: widget.job.id,
            revieweeId: widget.revieweeId,
            rating: _rating.round(),
            comment: comment,
          );
      if (mounted) setState(() => _isSuccess = true);
    } catch (e) {
      if (mounted) {
        ProlanceMessenger.error(
          context,
          context.read<AppState>().t('Error: $e', 'Hata: $e'),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Değerlendirme Yaz',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isSuccess ? _buildSuccess(scheme) : _buildForm(scheme),
    );
  }

  Widget _buildSuccess(ColorScheme scheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.star1,
                color: Colors.green,
                size: 44,
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.4, 0.4),
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                ),
            const SizedBox(height: 24),
            Text(
              'Değerlendirmeniz Gönderildi!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 8),
            Text(
              '${widget.revieweeName} adlı kullanıcıya\ndeğerlendirmeniz iletildi.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: scheme.onSurfaceVariant,
                height: 1.5,
              ),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Iconsax.tick_circle, size: 18),
              label: Text(
                'Tamam',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(ColorScheme scheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Reviewee info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  backgroundImage: widget.revieweeAvatar.isNotEmpty
                      ? NetworkImage(widget.revieweeAvatar)
                      : null,
                  child: widget.revieweeAvatar.isEmpty
                      ? Text(
                          widget.revieweeName.isNotEmpty
                              ? widget.revieweeName[0].toUpperCase()
                              : '?',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.revieweeName,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                      Text(
                        widget.job.title,
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
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 28),

          // Rating
          Text(
            'Puanınız',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              itemCount: 5,
              allowHalfRating: false,
              itemSize: 48,
              itemBuilder: (context, _) => const Icon(
                Iconsax.star1,
                color: AppColors.warning,
              ),
              onRatingUpdate: (r) => setState(() => _rating = r),
            ),
          ).animate().fadeIn(delay: 100.ms).scale(
                begin: const Offset(0.8, 0.8),
                duration: 400.ms,
                curve: Curves.easeOut,
              ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              _ratingLabel(_rating.round()),
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Comment
          Text(
            'Yorumunuz',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _commentController,
            maxLines: 5,
            style: GoogleFonts.poppins(fontSize: 14, color: scheme.onSurface),
            decoration: InputDecoration(
              hintText:
                  'Bu kişiyle çalışma deneyiminizi paylaşın...',
              hintStyle: GoogleFonts.poppins(
                fontSize: 14,
                color: scheme.onSurfaceVariant,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              ),
              alignLabelWithHint: true,
            ),
          ).animate().fadeIn(delay: 150.ms),

          const SizedBox(height: 32),

          FilledButton.icon(
            onPressed: _isLoading ? null : _submit,
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Iconsax.send_1, size: 18),
            label: Text(
              _isLoading ? 'Gönderiliyor...' : 'Değerlendirmeyi Gönder',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              ),
            ),
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }

  String _ratingLabel(int r) {
    switch (r) {
      case 1:
        return 'Çok Kötü';
      case 2:
        return 'Kötü';
      case 3:
        return 'Orta';
      case 4:
        return 'İyi';
      default:
        return 'Mükemmel';
    }
  }
}
