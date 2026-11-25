import 'package:flutter_test/flutter_test.dart';
import 'package:sabil_life/data/api/listing_parser.dart';

void main() {
  final valid = {
    'id': 'e1',
    'listing': 'l1',
    'title': 'Open day',
    'starts_at': '2026-12-01T10:00:00Z',
    'published_at': '2026-11-01T10:00:00Z',
  };

  test('malformed events are skipped and valid ones kept', () {
    final events = ListingParser.parseEvents([
      {...valid, 'id': 5},
      {...valid, 'published_at': null},
      {...valid, 'starts_at': 'not a date'},
      'not a map',
      valid,
    ]);
    expect(events.map((e) => e.id), ['e1']);
  });

  test('missing or non-list events parse as empty', () {
    expect(ListingParser.parseEvents(null), isEmpty);
    expect(ListingParser.parseEvents('bad'), isEmpty);
  });
}
