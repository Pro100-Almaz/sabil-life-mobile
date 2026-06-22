import '../models/review.dart';

final List<Review> _reviewPool = [
  Review(
    id: 'mock-rev-1',
    authorName: 'Aigerim K.',
    rating: 5,
    text:
        'We moved to Doha last year and this place made settling in so much easier. The staff remember every child by name.',
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    monthsAgo: 1,
  ),
  Review(
    id: 'mock-rev-2',
    authorName: 'Sarah M.',
    rating: 4,
    text:
        'Really well organised and the kids genuinely look forward to every session. Booking and communication are smooth.',
    createdAt: DateTime.now().subtract(const Duration(days: 60)),
    monthsAgo: 2,
  ),
  Review(
    id: 'mock-rev-3',
    authorName: 'Dmitry P.',
    rating: 5,
    text:
        'Excellent value for the quality. My daughter has progressed faster than we expected and always comes home happy.',
    createdAt: DateTime.now().subtract(const Duration(days: 90)),
    monthsAgo: 3,
  ),
  Review(
    id: 'mock-rev-4',
    authorName: 'Fatima A.',
    rating: 4,
    text:
        'Lovely atmosphere and friendly team. Parking can be tricky at peak times, so come a little early.',
    createdAt: DateTime.now().subtract(const Duration(days: 120)),
    monthsAgo: 4,
  ),
  Review(
    id: 'mock-rev-5',
    authorName: 'James T.',
    rating: 4,
    text:
        'Clean, professional and well run. They were flexible when we needed to change our schedule mid-term.',
    createdAt: DateTime.now().subtract(const Duration(days: 180)),
    monthsAgo: 6,
  ),
  Review(
    id: 'mock-rev-6',
    authorName: 'Madina S.',
    rating: 5,
    text:
        'The team speaks several languages, which helped our youngest feel at home from day one. Highly recommended.',
    createdAt: DateTime.now().subtract(const Duration(days: 240)),
    monthsAgo: 8,
  ),
];

/// In-memory reviews appended by [MockReviewRepository.create].
final Map<String, List<Review>> _mockReviewsByListing = {};

/// Deterministic per-listing slice of the review pool so each listing shows
/// a stable, distinct set of mock reviews.
List<Review> reviewsForListing(String listingId) {
  final extra = _mockReviewsByListing[listingId] ?? [];
  final offset = listingId.hashCode.abs() % _reviewPool.length;
  final base = List.generate(
    3,
    (i) => _reviewPool[(offset + i) % _reviewPool.length],
  );
  return [...extra, ...base];
}

/// Append a review to the in-memory store (used by MockReviewRepository).
void addMockReview(String listingId, Review review) {
  _mockReviewsByListing[listingId] = [
    review,
    ...(_mockReviewsByListing[listingId] ?? []),
  ];
}

/// Replace a review in the in-memory store by id.
void updateMockReview(Review updated) {
  for (final entry in _mockReviewsByListing.entries) {
    final idx = entry.value.indexWhere((r) => r.id == updated.id);
    if (idx != -1) {
      entry.value[idx] = updated;
      return;
    }
  }
}

/// Remove a review from the in-memory store by id.
void removeMockReview(String reviewId) {
  for (final list in _mockReviewsByListing.values) {
    list.removeWhere((r) => r.id == reviewId);
  }
}
