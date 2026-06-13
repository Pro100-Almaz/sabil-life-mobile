import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/state/filter_provider.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/util/distance.dart';
import '../../data/mock/mock_listings.dart';
import '../../data/models/listing.dart';
import 'widgets/category_strip.dart';
import 'widgets/listing_card.dart';
import 'widgets/search_pill.dart';
import 'widgets/section_header.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  List<Listing> _matchingQuery(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return List.of(mockListings);
    return mockListings.where((listing) {
      final haystack =
          '${listing.title} ${listing.subtitle} '
                  '${listing.neighborhood}'
              .toLowerCase();
      return haystack.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final query = ref.watch(filterProvider.select((f) => f.query));

    final matching = _matchingQuery(query);
    final featured = matching.where((listing) => listing.isFeatured).toList();
    final nearYou = List.of(matching)
      ..sort((a, b) => a.distanceFromHomeKm.compareTo(b.distanceFromHomeKm));
    final popular = List.of(matching)
      ..sort((a, b) => b.reviewCount.compareTo(a.reviewCount));

    return Scaffold(
      body: SafeArea(
        child: ListView(
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
                onAction: () => context.push(
                  '/category/${CategoryType.entertainment.name}',
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
              onAction: () =>
                  context.push('/category/${CategoryType.activities.name}'),
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
      ),
    );
  }
}
