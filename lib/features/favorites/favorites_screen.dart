import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/state/favorites_provider.dart';
import '../../core/state/provider_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/app_refresh_indicator.dart';
import '../home/widgets/listing_card_wide.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final savedIds = ref.watch(favoritesProvider);

    if (savedIds.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.navFavorites, style: AppTypography.display),
          toolbarHeight: 72,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.favorite_outline,
                size: 48,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(l10n.noFavorites, style: AppTypography.h3),
              const SizedBox(height: AppSpacing.xs),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxxl,
                ),
                child: Text(
                  l10n.noFavoritesHint,
                  style: AppTypography.caption,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navFavorites, style: AppTypography.display),
        toolbarHeight: 72,
      ),
      body: AppRefreshIndicator(
        onRefresh: () => Future.wait(
          savedIds.map((id) => ref.refresh(catalogDetailProvider(id).future)),
        ),
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: savedIds.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSpacing.lg),
          itemBuilder: (context, index) {
            final id = savedIds.elementAt(index);
            final asyncListing = ref.watch(catalogDetailProvider(id));
            return asyncListing.when(
              loading: () => const SizedBox(
                height: 80,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                ),
              ),
              error: (e, st) => ListTile(
                leading: const Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.textTertiary,
                ),
                title: Text(
                  l10n.listingNoLongerAvailable,
                  style: AppTypography.caption,
                ),
              ),
              data: (listing) => ListingCardWide(listing: listing),
            );
          },
        ),
      ),
    );
  }
}
