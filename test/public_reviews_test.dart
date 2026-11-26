import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sabil_life/core/state/provider_providers.dart';
import 'package:sabil_life/data/models/review.dart';
import 'package:sabil_life/data/repositories/review_repository.dart';
import 'package:sabil_life/data/repositories/tutor_review_repository.dart';

final _reviews = [
  for (final name in ['Aisha', '', '  '])
    Review(
      id: 'id-$name',
      rating: 5,
      text: 'text',
      authorName: name,
      createdAt: DateTime(2026),
    ),
];

class _ListingRepo extends Fake implements ReviewRepository {
  @override
  Future<List<Review>> forListing(String listingId, {int page = 1}) async =>
      _reviews;
}

class _TutorRepo extends Fake implements TutorReviewRepository {
  @override
  Future<List<Review>> forTutor(String tutorId, {int page = 1}) async =>
      _reviews;
}

void main() {
  test('reviews without an author are hidden from public lists', () async {
    final container = ProviderContainer(
      overrides: [
        reviewRepositoryProvider.overrideWithValue(_ListingRepo()),
        tutorReviewRepositoryProvider.overrideWithValue(_TutorRepo()),
      ],
    );
    addTearDown(container.dispose);
    final listing = await container.read(listingReviewsProvider('l').future);
    final tutor = await container.read(tutorReviewsProvider('t').future);
    expect(listing.map((r) => r.authorName), ['Aisha']);
    expect(tutor.map((r) => r.authorName), ['Aisha']);
  });
}
