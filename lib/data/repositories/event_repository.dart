import '../models/listing_event.dart';

abstract class EventRepository {
  Future<EventPage> forListing(
    String listingId, {
    int page = 1,
    bool owned = false,
  });
  Future<ListingEvent> publish(String listingId, Map<String, dynamic> fields);
}
