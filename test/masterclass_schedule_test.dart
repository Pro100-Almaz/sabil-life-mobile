import 'package:flutter_test/flutter_test.dart';
import 'package:sabil_life/data/api/listing_parser.dart';
import 'package:sabil_life/data/models/listing.dart';

void main() {
  test('parses a one-time masterclass schedule from the API', () {
    final listing = ListingParser.fromCard({
      'id': 'event-1',
      'title': 'Pottery workshop',
      'category': 'MASTERCLASSES',
      'event_type': 'ONE_TIME',
      'starts_at': '2026-09-01T15:30:00Z',
    });

    expect(listing.eventType, MasterclassEventType.oneTime);
    expect(listing.startsAt?.toUtc(), DateTime.utc(2026, 9, 1, 15, 30));
  });

  test('serializes supported masterclass event types', () {
    expect(
      ListingParser.serializeEventType(MasterclassEventType.oneTime),
      'ONE_TIME',
    );
    expect(
      ListingParser.serializeEventType(MasterclassEventType.ongoing),
      'ONGOING',
    );
  });
}
