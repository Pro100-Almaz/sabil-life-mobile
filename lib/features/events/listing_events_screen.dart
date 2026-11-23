import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/state/event_providers.dart';
import 'listing_event_card.dart';

class ListingEventsScreen extends ConsumerStatefulWidget {
  const ListingEventsScreen({
    super.key,
    required this.listingId,
    this.owned = false,
  });
  final String listingId;
  final bool owned;
  @override
  ConsumerState<ListingEventsScreen> createState() =>
      _ListingEventsScreenState();
}

class _ListingEventsScreenState extends ConsumerState<ListingEventsScreen> {
  int _pages = 1;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = List.generate(
      _pages,
      (i) => ref.watch(
        listingEventsProvider((
          listingId: widget.listingId,
          page: i + 1,
          owned: widget.owned,
        )),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.listingEvents),
        actions: [
          if (widget.owned &&
              pages.first.hasValue &&
              !pages.any((p) => p.hasError))
            IconButton(
              tooltip: l10n.createListingEvent,
              icon: const Icon(Icons.add),
              onPressed: () =>
                  context.push('${GoRouterState.of(context).uri.path}/new'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(listingEventsProvider);
          setState(() => _pages = 1);
          await ref.read(
            listingEventsProvider((
              listingId: widget.listingId,
              page: 1,
              owned: widget.owned,
            )).future,
          );
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            for (var i = 0; i < pages.length; i++)
              pages[i].when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Column(
                  children: [
                    Text(l10n.genericLoadError),
                    TextButton(
                      onPressed: () => ref.invalidate(
                        listingEventsProvider((
                          listingId: widget.listingId,
                          page: i + 1,
                          owned: widget.owned,
                        )),
                      ),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
                data: (page) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (i == 0 && page.results.isEmpty)
                      Text(l10n.eventNoEvents),
                    for (final event in page.results)
                      ListingEventCard(event: event),
                    if (i == _pages - 1 && page.hasNext)
                      TextButton(
                        onPressed: () => setState(() => _pages++),
                        child: Text(l10n.eventLoadMore),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
