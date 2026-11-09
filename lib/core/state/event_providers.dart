import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/api/events.dart';
import '../../data/models/listing_event.dart';
import '../../data/repositories/event_repository.dart';
import 'auth_provider.dart';

final eventRepositoryProvider = Provider<EventRepository>(
  (ref) => HttpEventRepository(),
);
final listingEventsProvider = FutureProvider.autoDispose
    .family<EventPage, ({String listingId, int page, bool owned})>((ref, key) {
      if (key.owned) ref.watch(authProvider);
      return ref
          .watch(eventRepositoryProvider)
          .forListing(key.listingId, page: key.page, owned: key.owned);
    });
