/// Shared by inbox and device pushes. Ignore incomplete event payloads.
String? providerEventLocation(Map<String, dynamic> data) {
  final listingId = data['listing_id'];
  final eventId = data['event_id'];
  if (listingId is! String ||
      listingId.isEmpty ||
      eventId is! String ||
      eventId.isEmpty) {
    return null;
  }
  return '/listing/${Uri.encodeComponent(listingId)}/events';
}
