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
      // Owned results are per-account: refetch on account/token change only.
      if (key.owned) {
        ref.watch(authProvider.select((s) => (id: s.user?.id, token: s.token)));
      }
      return ref
          .watch(eventRepositoryProvider)
          .forListing(key.listingId, page: key.page, owned: key.owned);
    });
