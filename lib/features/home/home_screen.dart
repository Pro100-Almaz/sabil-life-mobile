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
        child: asyncListings.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (e, _) => Center(
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
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.listings});

  final List<Listing> listings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final featured = listings.where((l) => l.isFeatured).toList();
    final popular = List.of(listings)
      ..sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    final nearYou = List.of(listings)
      ..sort((a, b) => a.distanceFromHomeKm.compareTo(b.distanceFromHomeKm));

    return ListView(
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
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
            onAction: () =>
                context.push('/category/${CategoryType.entertainment.name}'),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 300,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
    );
  }
}
