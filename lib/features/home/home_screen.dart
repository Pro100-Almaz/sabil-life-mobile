import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/state/filter_provider.dart';
import '../../core/state/provider_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/util/distance.dart';
import '../../data/models/listing.dart';
import '../../shared/widgets/app_refresh_indicator.dart';
import 'widgets/category_strip.dart';
import 'widgets/listing_card.dart';
import 'widgets/search_pill.dart';
import 'widgets/section_header.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncListings = ref.watch(filteredListingsProvider);

    return Scaffold(
      body: SafeArea(
        child: AppRefreshIndicator(
          onRefresh: () => ref.refresh(
            catalogListingsProvider(ref.read(listingsFilterProvider)).future,
          ),
          child: asyncListings.when(
            loading: () => const RefreshableMessage(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (e, _) => RefreshableMessage(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.genericLoadError, textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: () => ref.invalidate(catalogListingsProvider),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            ),
            data: (listings) => _HomeContent(listings: listings),
          ),
        ),
      ),
    );
  }
}

class _HomeContent extends ConsumerStatefulWidget {
  const _HomeContent({required this.listings});

  final List<Listing> listings;

  @override
  ConsumerState<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends ConsumerState<_HomeContent> {
  final _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final show = _scrollController.offset > 300;
    if (show != _showScrollToTop) setState(() => _showScrollToTop = show);
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  void _applyfilters(FilterState state) {
    final sortMode = switch (state.sortMode) {
      SortMode.priceLow => 'priceLow',
      SortMode.distance => 'distance',
      SortMode.rating => 'rating',
    };
    context.push(
      '/category/${state.selectedCategory}?sort=$sortMode&maxDistanceKm=${state.maxDistanceKm}&ageGroup=${state.ageGroup}&priceMax=${state.priceMax}', //popular in doha to entertainment
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final origin = ref.watch(filterProvider.select((f) => f.userPosition));
    final featured = widget.listings.where((l) => l.isFeatured).toList();
    final popular = List.of(widget.listings)
      ..sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    final nearYou = List.of(widget.listings)
      ..sort(
        (a, b) => a
            .distanceFromHomeKm(origin)
            .compareTo(b.distanceFromHomeKm(origin)),
      );

    return Stack(
      children: [
        ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: SearchPill(),
            ),
            const CategoryStrip(),
            const SizedBox(height: AppSpacing.xxl),
            if (featured.isNotEmpty) ...[
              SectionHeader(title: l10n.featured),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 300,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  itemCount: featured.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: AppSpacing.lg),
                  itemBuilder: (context, index) =>
                      ListingCard(listing: featured[index], width: 280),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
            if (popular.isNotEmpty) ...[
              SectionHeader(
                title: l10n.popularInDoha,
                actionLabel: l10n.seeAll,
                onAction: () => _applyfilters(
                  FilterState(
                    selectedCategory: null,
                    sortMode: SortMode.rating,
                    maxDistanceKm: 30,
                    ageGroup: null,
                    priceMax: 50000,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 300,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  itemCount: popular.length.clamp(0, 8),
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: AppSpacing.lg),
                  itemBuilder: (context, index) =>
                      ListingCard(listing: popular[index], width: 280),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
            SectionHeader(
              title: l10n.nearYou,
              actionLabel: l10n.seeAll,
              onAction: () => _applyfilters(
                FilterState(
                  selectedCategory: null,
                  sortMode: SortMode.distance,
                  maxDistanceKm: 10,
                  ageGroup: null,
                  priceMax: 50000,
                ),
              ), //near you to activities
            ),
            const SizedBox(height: AppSpacing.md),
            if (nearYou.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xxxl),
                child: Center(child: Text(l10n.noResults)),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  children: [
                    for (final listing in nearYou.take(10)) ...[
                      ListingCard(listing: listing),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ],
                ),
              ),
          ],
        ),
        Positioned(
          right: AppSpacing.lg,
          bottom: AppSpacing.lg,
          child: AnimatedScale(
            scale: _showScrollToTop ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: FloatingActionButton.small(
              heroTag: 'scroll_to_top',
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textPrimary,
              elevation: 2,
              onPressed: _scrollToTop,
              child: const Icon(Icons.arrow_upward, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}
