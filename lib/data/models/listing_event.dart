class ListingEvent {
  const ListingEvent({
    required this.id,
    required this.listingId,
    required this.title,
    required this.description,
    required this.startsAt,
    this.endsAt,
    required this.location,
    required this.registrationUrl,
    required this.publishedAt,
  });
  final String id, listingId, title, description, location, registrationUrl;
  final DateTime startsAt, publishedAt;
  final DateTime? endsAt;

  factory ListingEvent.fromJson(Map<String, dynamic> json) => ListingEvent(
    id: json['id'] as String,
    listingId: json['listing'] as String,
    title: json['title'] as String,
    description: json['description'] as String? ?? '',
    startsAt: DateTime.parse(json['starts_at'] as String).toLocal(),
    endsAt: json['ends_at'] == null
        ? null
        : DateTime.parse(json['ends_at'] as String).toLocal(),
    location: json['location'] as String? ?? '',
    registrationUrl: json['registration_url'] as String? ?? '',
    publishedAt: DateTime.parse(json['published_at'] as String),
  );
}

class EventPage {
  const EventPage({required this.results, required this.hasNext});
  final List<ListingEvent> results;
  final bool hasNext;
}

List<ListingEvent> latestListingEvents(List<ListingEvent> events) {
  final sorted = [...events]
    ..sort((a, b) {
      final date = b.publishedAt.compareTo(a.publishedAt);
      return date == 0 ? b.id.compareTo(a.id) : date;
    });
  return sorted.take(2).toList();
}
