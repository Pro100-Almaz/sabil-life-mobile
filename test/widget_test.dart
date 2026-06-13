import 'package:flutter_test/flutter_test.dart';
import 'package:sabil_life/core/util/distance.dart';
import 'package:sabil_life/data/mock/mock_listings.dart';
import 'package:sabil_life/data/mock/mock_masterclasses.dart';
import 'package:sabil_life/data/mock/mock_tutors.dart';
import 'package:sabil_life/data/models/listing.dart';

void main() {
  test('mock data sanity: ≥24 listings, every category ≥2 entries', () {
    expect(mockListings.length, greaterThanOrEqualTo(24));

    for (final category in CategoryType.values) {
      final count = mockListings.where((l) => l.category == category).length;
      expect(
        count,
        greaterThanOrEqualTo(2),
        reason: 'category $category has only $count listings',
      );
    }

    final featured = mockListings.where((l) => l.isFeatured).length;
    expect(featured, greaterThanOrEqualTo(5));

    final ids = mockListings.map((l) => l.id).toSet();
    expect(ids.length, mockListings.length, reason: 'duplicate listing ids');
  });

  test('tutors: ≥6, valid centre affiliations, every centre covered', () {
    expect(mockTutors.length, greaterThanOrEqualTo(6));

    final centreIds = mockListings
        .where((l) => l.category == CategoryType.tutoring)
        .map((l) => l.id)
        .toSet();
    for (final tutor in mockTutors) {
      expect(
        centreIds.contains(tutor.affiliationListingId),
        isTrue,
        reason:
            '${tutor.id} points at unknown centre '
            '${tutor.affiliationListingId}',
      );
      expect(tutor.subjects, isNotEmpty);
      expect(tutor.formats, isNotEmpty);
      expect(tutor.pricePerHourQar, greaterThan(0));
    }
    for (final centreId in centreIds) {
      expect(
        mockTutors.any((t) => t.affiliationListingId == centreId),
        isTrue,
        reason: 'centre $centreId has no tutors',
      );
    }
  });

  test('masterclasses: every listing has info with ≥2 future sessions', () {
    final masterclassIds = mockListings
        .where((l) => l.category == CategoryType.masterclasses)
        .map((l) => l.id);
    for (final id in masterclassIds) {
      final info = mockMasterclassInfo[id];
      expect(info, isNotNull, reason: '$id has no masterclass info');
      final future = info!.sessions
          .where((s) => s.start.isAfter(DateTime.now()))
          .length;
      expect(
        future,
        greaterThanOrEqualTo(2),
        reason: '$id has only $future future sessions',
      );
      expect(info.durationMin, greaterThan(0));
      for (final session in info.sessions) {
        expect(session.seatsLeft, greaterThan(0));
      }
    }
  });

  test('every listing is within 30 km of the mock home', () {
    for (final listing in mockListings) {
      expect(
        listing.distanceFromHomeKm,
        lessThan(30),
        reason: '${listing.id} is too far from home',
      );
      expect(listing.imageUrls, isNotEmpty);
      expect(listing.highlights.length, inInclusiveRange(3, 5));
      expect(listing.ageGroups, isNotEmpty);
    }
  });
}
