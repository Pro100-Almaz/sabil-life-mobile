import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/state/auth_provider.dart';
import '../../core/state/provider_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/listing.dart';
import '../../data/models/ownership_request.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../shared/widgets/app_refresh_indicator.dart';
import 'widgets/claim_listing_card.dart';

/// Directory listings are created by the platform. Providers can request to
/// take ownership, then edit the listing after that request is approved.
///
/// Searches the whole catalog and pages through results on scroll, so any
/// listing can be found, not just the top-rated first page.
class ClaimListingScreen extends ConsumerStatefulWidget {
  const ClaimListingScreen({super.key});

  @override
  ConsumerState<ClaimListingScreen> createState() => _ClaimListingScreenState();
}

class _ClaimListingScreenState extends ConsumerState<ClaimListingScreen> {
  final _search = TextEditingController();
  final _scroll = ScrollController();
  Timer? _debounce;

  final _items = <Listing>[];
  final _seenIds = <String>{};
  int _nextPage = 1;
  bool _hasNext = true;
  bool _loadingPage = false;
  Object? _error;

  /// Bumped on every reset so responses for a stale query are dropped.
  int _generation = 0;

  /// Requests sent from this screen, shown as requested before the request
  /// list refetches.
  final _sentIds = <String>{};
  String? _claimingId;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _loadMore();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.extentAfter < 400) _loadMore();
  }

  void _onQueryChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _reset);
  }

  Future<void> _reset() {
    setState(() {
      _generation++;
      _items.clear();
      _seenIds.clear();
      _nextPage = 1;
      _hasNext = true;
      _loadingPage = false;
      _error = null;
    });
    return _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loadingPage || !_hasNext) return;
    final generation = _generation;
    setState(() {
      _loadingPage = true;
      _error = null;
    });
    try {
      final query = _search.text.trim();
      final page = await ref
          .read(catalogRepositoryProvider)
          .listings(
            query: query.isEmpty ? null : query,
            sort: ListingSort.rating,
            page: _nextPage,
          );
      if (!mounted || generation != _generation) return;
      setState(() {
        for (final listing in page.results) {
          if (_seenIds.add(listing.id)) _items.add(listing);
        }
        _nextPage++;
        _hasNext = page.hasNext;
        _loadingPage = false;
      });
      // A short or fully filtered page may not fill the viewport (or show
      // any list at all), so keep loading until it does or pages run out.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _scroll.hasClients ? _onScroll() : _loadMore();
      });
    } catch (error) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _error = error;
        _loadingPage = false;
      });
    }
  }

  Future<void> _claim(Listing listing) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _claimingId = listing.id);
    try {
      await ref
          .read(providerRepositoryProvider)
          .requestListingOwnership(listing.id);
      _sentIds.add(listing.id);
      ref.invalidate(myOwnershipRequestsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.ownershipRequestSent)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is StateError ? error.message : l10n.genericLoadError,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _claimingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authProvider).user;

    // Catalog cards carry no owner, so exclude the provider's own listings
    // by id and mark listings that already have a pending request.
    final ownedIds = {
      for (final listing
          in (user == null
                  ? null
                  : ref.watch(myListingsProvider(user.id)).valueOrNull) ??
              const <Listing>[])
        listing.id,
    };
    final pendingIds = {
      ..._sentIds,
      for (final request
          in ref.watch(myOwnershipRequestsProvider).valueOrNull ??
              const <OwnershipRequest>[])
        if (request.status == OwnershipRequestStatus.pending) request.listingId,
    };
    final available = _items
        .where(
          (listing) =>
              listing.category != CategoryType.masterclasses &&
              !ownedIds.contains(listing.id),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.claimListing),
        actions: [
          IconButton(
            tooltip: l10n.ownershipRequests,
            icon: const Icon(Icons.history_outlined),
            onPressed: () =>
                context.push('/provider/masterclass/listings/requests'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              0,
            ),
            child: TextField(
              controller: _search,
              onChanged: _onQueryChanged,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) {
                _debounce?.cancel();
                _reset();
              },
              decoration: InputDecoration(
                hintText: l10n.searchListingsToClaim,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: AppRefreshIndicator(
              onRefresh: () {
                ref.invalidate(myOwnershipRequestsProvider);
                return _reset();
              },
              child: _buildList(l10n, available, pendingIds),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
    AppLocalizations l10n,
    List<Listing> available,
    Set<String> pendingIds,
  ) {
    if (available.isEmpty) {
      if (_error != null) {
        return RefreshableMessage(child: Text(l10n.genericLoadError));
      }
      if (_loadingPage || _hasNext) {
        return const RefreshableMessage(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }
      return RefreshableMessage(child: Text(l10n.noListingsYet));
    }

    final showFooter = _hasNext || _error != null;
    return ListView.separated(
      controller: _scroll,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: available.length + (showFooter ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        if (index == available.length) {
          return Center(
            child: _error != null
                ? TextButton(
                    onPressed: _loadMore,
                    child: Text(l10n.genericLoadError),
                  )
                : const Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
          );
        }
        final listing = available[index];
        return ClaimListingCard(
          listing: listing,
          requested: pendingIds.contains(listing.id),
          claiming: _claimingId == listing.id,
          onClaim: _claimingId == null ? () => _claim(listing) : null,
        );
      },
    );
  }
}
