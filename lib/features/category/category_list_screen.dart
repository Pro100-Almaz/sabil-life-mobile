import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/state/filter_provider.dart';
import '../../core/state/provider_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/util/category_label.dart';
import '../../core/util/location_service.dart';
import '../../data/models/listing.dart';
import '../../shared/widgets/app_refresh_indicator.dart';
import '../../shared/widgets/pill_chip.dart';
import '../home/widgets/listing_card.dart';
import 'widgets/filter_sheet.dart';
import 'widgets/sort_menu.dart';
import 'widgets/search_pill.dart';

class CategoryListScreen extends ConsumerStatefulWidget {
  const CategoryListScreen({
    super.key,
    required this.category,
    this.initialAgeGroup,
    this.initialMaxDistance,
    this.initialPriceMax,
    this.initialSort,
  });

  /// Null = "all categories" (e.g. an unknown route param).
  final CategoryType? category;
  final SortMode? initialSort;
  final String? initialAgeGroup;
  final int? initialPriceMax;
  final double? initialMaxDistance;
  @override
  ConsumerState<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends ConsumerState<CategoryListScreen> {
  late final FilterNotifier _filter;
  bool _searchOptionsEnabled = false;

  void enableSearchOptions() {
    setState(() => _searchOptionsEnabled = !_searchOptionsEnabled);
  }

  @override
  void initState() {
    super.initState();
    _filter = ref.read(filterProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _filter.setCategory(widget.category);
      _filter.resetFilters();
      _filter.setSortMode(widget.initialSort ?? SortMode.distance);

      final userPosition = await ref
          .read(locationServiceProvider)
          .getUserLocation();
      _filter.applyFilters(
        maxDistanceKm: widget.initialMaxDistance ?? 30,
        priceMax: widget.initialPriceMax ?? 50000,
        ageGroup: widget.initialAgeGroup,
        userPosition: userPosition,
      );
    });
  }

  @override
  void dispose() {
    final filter = _filter;
    Future.microtask(() {
      filter.setCategory(null);
      filter.resetFilters();
      filter.setSortMode(SortMode.distance);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final asyncListings = ref.watch(filteredListingsProvider);
    final asyncTags = ref.watch(categoryTagsProvider(widget.category));
    final filter = ref.watch(filterProvider);
    final title = widget.category == null
        ? l10n.catAll
        : widget.category!.label(l10n);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SizedBox(height: 48, child: SearchPill(title: title)),
            ),
            SizedBox(width: AppSpacing.sm),
            SizedBox.square(
              dimension: 48,
              child: IconButton(
                onPressed: enableSearchOptions,
                icon: const Icon(Icons.tune, size: 20),
              ),
            ),
            SizedBox(width: AppSpacing.md),

            // asyncListings.when(
            //   loading: () => Text(l10n.loading, style: AppTypography.small),
            //   error: (e, st) => const SizedBox.shrink(),
            //   data: (page) => Text(
            //     l10n.resultsCount(page.count),
            //     style: AppTypography.small,
            //   ),
            // ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          //listing tags
          SizedBox(
            height: 40,
            child: asyncTags.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (tags) => tags.isEmpty
                  ? const SizedBox.shrink()
                  : ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      children: [
                        PillChip(
                          label: l10n.catAll,
                          selected: filter.tag == null,
                          onTap: () =>
                              ref.read(filterProvider.notifier).setTag(null),
                        ),
                        for (final tag in tags) ...[
                          const SizedBox(width: AppSpacing.sm),
                          PillChip(
                            label: tag,
                            selected: filter.tag == tag,
                            onTap: () => ref
                                .read(filterProvider.notifier)
                                .setTag(filter.tag == tag ? null : tag),
                          ),
                        ],
                      ],
                    ),
            ),
          ),
          SizedBox(height: _searchOptionsEnabled ? 0 : AppSpacing.sm),
          //search filters and sort options
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: _searchOptionsEnabled
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        _ToolbarButton(
                          icon: Icons.tune,
                          label: l10n.filters,
                          highlighted: filter.hasActiveFilters,
                          onTap: () => showFilterSheet(context),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _ToolbarButton(
                          icon: Icons.swap_vert,
                          label: l10n.sort,
                          highlighted: filter.sortMode != SortMode.distance,
                          onTap: () => showSortMenu(context),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const Divider(),
          Expanded(
            child: AppRefreshIndicator(
              onRefresh: () => ref.refresh(
                catalogListingsProvider(
                  ref.read(listingsFilterProvider),
                ).future,
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
                        onPressed: () =>
                            ref.invalidate(catalogListingsProvider),
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
                data: (page) {
                  final listings = page.results;
                  return listings.isEmpty
                      ? RefreshableMessage(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.search_off,
                                size: 48,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(l10n.noResults, style: AppTypography.h3),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                l10n.noResultsHint,
                                style: AppTypography.caption,
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                itemCount: listings.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: AppSpacing.xxl),
                                itemBuilder: (context, index) =>
                                    ListingCard(listing: listings[index]),
                              ),
                            ),
                            _PageControllerPill(
                              page: filter.page,
                              hasPrevious: page.hasPrevious,
                              hasNext: page.hasNext,
                              onPrevious: () => ref
                                  .read(filterProvider.notifier)
                                  .previousPage(),
                              onNext: () =>
                                  ref.read(filterProvider.notifier).nextPage(),
                            ),
                          ],
                        );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageControllerPill extends StatelessWidget {
  const _PageControllerPill({
    required this.page,
    required this.hasPrevious,
    required this.hasNext,
    required this.onPrevious,
    required this.onNext,
  });

  final int page;
  final bool hasPrevious;
  final bool hasNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: hasPrevious ? onPrevious : null,
            ),
            Text('$page', style: AppTypography.label),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: hasNext ? onNext : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: Border.all(
            color: highlighted ? AppColors.textPrimary : AppColors.border,
            width: highlighted ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.textPrimary),
            const SizedBox(width: AppSpacing.xs),
            Text(label, style: AppTypography.label),
          ],
        ),
      ),
    );
  }
}
