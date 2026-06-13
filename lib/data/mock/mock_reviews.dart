import '../models/review.dart';

const List<Review> _reviewPool = [
  Review(
    author: 'Aigerim K.',
    rating: 5.0,
    text:
        'We moved to Doha last year and this place made settling in so much easier. The staff remember every child by name.',
    monthsAgo: 1,
  ),
  Review(
    author: 'Sarah M.',
    rating: 4.5,
    text:
        'Really well organised and the kids genuinely look forward to every session. Booking and communication are smooth.',
    monthsAgo: 2,
  ),
  Review(
    author: 'Dmitry P.',
    rating: 5.0,
    text:
        'Excellent value for the quality. My daughter has progressed faster than we expected and always comes home happy.',
    monthsAgo: 3,
  ),
  Review(
    author: 'Fatima A.',
    rating: 4.0,
    text:
        'Lovely atmosphere and friendly team. Parking can be tricky at peak times, so come a little early.',
    monthsAgo: 4,
  ),
  Review(
    author: 'James T.',
    rating: 4.5,
    text:
        'Clean, professional and well run. They were flexible when we needed to change our schedule mid-term.',
    monthsAgo: 6,
  ),
  Review(
    author: 'Madina S.',
    rating: 5.0,
    text:
        'The team speaks several languages, which helped our youngest feel at home from day one. Highly recommended.',
    monthsAgo: 8,
  ),
];

/// Deterministic per-listing slice of the review pool so each listing shows
/// a stable, distinct set of mock reviews.
List<Review> reviewsForListing(String listingId) {
  final offset = listingId.hashCode.abs() % _reviewPool.length;
  return List.generate(
    3,
    (i) => _reviewPool[(offset + i) % _reviewPool.length],
  );
}
