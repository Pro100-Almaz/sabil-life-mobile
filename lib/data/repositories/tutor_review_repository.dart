import '../models/review.dart';
import 'review_repository.dart' show ReviewException;

/// Reviews for **tutors**. Separate from [ReviewRepository] (listings) because
/// the backend routes them on their own endpoints:
///   • create / list → `/tutors/{tutor_id}/reviews/`
///   • update / delete → `/tutor-reviews/{id}/`
abstract class TutorReviewRepository {
  /// Public reviews left for a tutor (newest-first).
  Future<List<Review>> forTutor(String tutorId, {int page = 1});

  /// Create a review for a tutor. The backend enforces the engagement-gate
  /// (the signed-in family must have an inquiry with this tutor in
  /// CONTACTED / ACCEPTED / COMPLETED) and the one-review-per-tutor rule,
  /// raising [ReviewException] when either fails.
  Future<Review> create({
    required String tutorId,
    required int rating,
    required String text,
  });

  /// Edit the family's own tutor review by id (`/tutor-reviews/{id}/`).
  Future<Review> update({required String reviewId, int? rating, String? text});

  /// Delete the family's own tutor review by id (`/tutor-reviews/{id}/`).
  Future<void> delete(String reviewId);
}
