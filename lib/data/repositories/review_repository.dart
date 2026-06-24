import '../mock/mock_reviews.dart';
import '../models/review.dart';

/// Thrown when the backend engagement-gate or duplicate-review rules fire.
class ReviewException implements Exception {
  const ReviewException(this.message);
  final String message;

  @override
  String toString() => 'ReviewException: $message';
}

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

class MockReviewRepository implements ReviewRepository {
  static const Duration _latency = Duration(milliseconds: 300);

  String? _currentUserId;
  String? _currentUserName;

  void setCurrentUser({required String id, required String name}) {
    _currentUserId = id;
    _currentUserName = name;
  }

  final List<Review> _mine = [];

  @override
  Future<List<Review>> forListing(String listingId, {int page = 1}) async {
    await Future<void>.delayed(_latency);
    return reviewsForListing(listingId);
  }

  @override
  Future<List<Review>> myReviews() async {
    await Future<void>.delayed(_latency);
    return List.unmodifiable(_mine);
  }

  @override
  Future<Review> create({
    required String listingId,
    required int rating,
    required String text,
  }) async {
    await Future<void>.delayed(_latency);
    final review = Review(
      id: 'rev-${DateTime.now().millisecondsSinceEpoch}',
      authorName: _currentUserName ?? 'You',
      authorId: _currentUserId,
      rating: rating,
      text: text,
      createdAt: DateTime.now(),
    );
    addMockReview(listingId, review);
    _mine.add(review);
    return review;
  }

  @override
  Future<Review> update({
    required String reviewId,
    int? rating,
    String? text,
  }) async {
    await Future<void>.delayed(_latency);
    final idx = _mine.indexWhere((r) => r.id == reviewId);
    if (idx == -1) throw StateError('Review not found: $reviewId');
    final updated = _mine[idx].copyWith(rating: rating, text: text);
    _mine[idx] = updated;
    updateMockReview(updated);
    return updated;
  }

  @override
  Future<void> delete(String reviewId) async {
    await Future<void>.delayed(_latency);
    _mine.removeWhere((r) => r.id == reviewId);
    removeMockReview(reviewId);
  }
}
