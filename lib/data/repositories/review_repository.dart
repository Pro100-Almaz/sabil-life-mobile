import '../models/review.dart';

/// Thrown when the backend engagement-gate or duplicate-review rules fire.
class ReviewException implements Exception {
  const ReviewException(this.message);
  final String message;

  @override
  String toString() => 'ReviewException: $message';
}

/// Reviews for **listings**. Tutor reviews live in their own repository
/// ([TutorReviewRepository]) because the backend routes them separately.
abstract class ReviewRepository {
  Future<List<Review>> forListing(String listingId, {int page = 1});
  Future<List<Review>> myReviews();
  Future<Review> create({
    required String listingId,
    required int rating,
    required String text,
  });
  Future<Review> update({required String reviewId, int? rating, String? text});
  Future<void> delete(String reviewId);
}
