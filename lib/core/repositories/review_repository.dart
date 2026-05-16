import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/review_model.dart';

/// Handles reading and writing to `public.reviews`.
///
/// RLS policies allow:
///   - SELECT for reviewer_id OR reviewee_id = auth.uid()
///   - INSERT when reviewer_id = auth.uid()
class ReviewRepository extends ChangeNotifier {
  ReviewRepository();

  SupabaseClient? get _client {
    if (!SupabaseConfig.isEnabled) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Submits a new review. Throws on error.
  Future<void> submitReview({
    required String jobId,
    required String revieweeId,
    required int rating,
    required String comment,
  }) async {
    final c = _client;
    if (c == null) return;

    final uid = c.auth.currentUser?.id;
    if (uid == null) throw StateError('Not authenticated');

    await c.from('reviews').insert({
      'job_id': jobId,
      'reviewer_id': uid,
      'reviewee_id': revieweeId,
      'rating': rating,
      'comment': comment,
    });
  }

  /// Loads all reviews for [profileId] (as reviewee), joining reviewer profile.
  /// Returns an empty list when Supabase is disabled or an error occurs.
  Future<List<ReviewModel>> loadReviewsForProfile(String profileId) async {
    final c = _client;
    if (c == null) return [];

    try {
      final rows = await c
          .from('reviews')
          .select('*, reviewer:reviewer_id(full_name, avatar_url)')
          .eq('reviewee_id', profileId)
          .order('created_at', ascending: false);

      return rows.map(ReviewModel.fromRow).toList();
    } catch (e) {
      debugPrint('[ReviewRepository] loadReviewsForProfile error: $e');
      return [];
    }
  }

  /// Returns true if the current user has already reviewed this job.
  Future<bool> hasReviewed(String jobId) async {
    final c = _client;
    if (c == null) return false;

    final uid = c.auth.currentUser?.id;
    if (uid == null) return false;

    try {
      final rows = await c
          .from('reviews')
          .select('id')
          .eq('job_id', jobId)
          .eq('reviewer_id', uid);
      return rows.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
