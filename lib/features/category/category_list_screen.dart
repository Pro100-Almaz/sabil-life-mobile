import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/state/filter_provider.dart';
import '../../core/state/provider_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/util/category_label.dart';
import '../../data/models/listing.dart';
import '../../shared/widgets/app_refresh_indicator.dart';
import '../home/widgets/listing_card.dart';
import 'widgets/filter_sheet.dart';
import 'widgets/sort_menu.dart';
import 'widgets/search_pill.dart';
import 'widgets/tag_group_rail.dart';

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

      final filter = ref.read(filterProvider);
      _filter.applyFilters(
        maxDistanceKm: widget.initialMaxDistance ?? 30,
        priceMax: widget.initialPriceMax ?? 50000,
        ageGroup: widget.initialAgeGroup,
        userPosition: filter.userPosition,
        distanceOrigin: filter.distanceOrigin,
      );
    });
  }

  @override
  void dispose() {
    final filter = _filter;
    Future.microtask(() {
      filter.setQuery('');
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
    final asyncTagGroups = ref.watch(
      categoryTagGroupsProvider(widget.category),
    );
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
          AnimatedSize(
            duration: const Duration(milliseconds: 100),
            child: asyncTagGroups.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (tagGroups) => tagGroups.isEmpty
                  ? const SizedBox.shrink()
                  : TagGroupRail(
                      groups: tagGroups,
                      selectedTags: filter.tags,
                      onToggleTag: (tag) =>
                          ref.read(filterProvider.notifier).toggleTag(tag),
                      onClear: () =>
                          ref.read(filterProvider.notifier).clearTags(),
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
                              totalPages: page.totalPages,
                              hasPrevious: page.hasPrevious,
                              hasNext: page.hasNext,
                              onPrevious: () => ref
                                  .read(filterProvider.notifier)
                                  .previousPage(),
                              onNext: () =>
                                  ref.read(filterProvider.notifier).nextPage(),
                              onJumpToPage: (target) => ref
                                  .read(filterProvider.notifier)
                                  .setPage(target),
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
    required this.totalPages,
    required this.hasPrevious,
    required this.hasNext,
    required this.onPrevious,
    required this.onNext,
    required this.onJumpToPage,
  });

  final int page;
  final int totalPages;
  final bool hasPrevious;
  final bool hasNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<int> onJumpToPage;

  List<int?> _buildPageItems() {
    if (totalPages <= 7) {
      return List.generate(totalPages, (i) => i + 1);
    }
    final keep = <int>{
      1,
      totalPages,
      if (page - 1 >= 1) page - 1,
      page,
      if (page + 1 <= totalPages) page + 1,
    }.toList()..sort();

    final items = <int?>[];
    for (var i = 0; i < keep.length; i++) {
      if (i > 0 && keep[i] - keep[i - 1] > 1) {
        items.add(null);
      }
      items.add(keep[i]);
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final items = _buildPageItems();
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: hasPrevious ? onPrevious : null,
              ),
              for (final item in items)
                item == null
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                        ),
                        child: Text('…', style: AppTypography.label),
                      )
                    : _PageNumber(
                        number: item,
                        isCurrent: item == page,
                        onTap: () => onJumpToPage(item),
                      ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: hasNext ? onNext : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageNumber extends StatelessWidget {
  const _PageNumber({
    required this.number,
    required this.isCurrent,
    required this.onTap,
  });

  final int number;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isCurrent ? null : onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isCurrent ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        child: Text(
          '$number',
          style: AppTypography.label.copyWith(
            color: isCurrent ? Colors.white : AppColors.textPrimary,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
          ),
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
