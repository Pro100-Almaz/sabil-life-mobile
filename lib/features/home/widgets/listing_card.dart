import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/util/distance.dart';
import '../../../core/state/filter_provider.dart';
import '../../../data/models/listing.dart';
import '../../../shared/widgets/heart_button.dart';
import '../../../shared/widgets/star_rating.dart';

/// The reusable Airbnb-style card: 16:10 photo, heart overlay, meta rows.
class ListingCard extends ConsumerWidget {
  const ListingCard({super.key, required this.listing, this.width});

  final Listing listing;

  /// Fixed width for horizontal carousels; null = fill available width.
  final double? width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final origin = ref.watch(filterProvider.select((f) => f.userPosition));
    final l10n = AppLocalizations.of(context)!;
    final imageUrl = listing.primaryImageUrl;
    return GestureDetector(
      onTap: () => context.push('/listing/${listing.id}'),
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.image),
                    child: imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Container(color: AppColors.surfaceAlt),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.surfaceAlt,
                              child: const Icon(
                                Icons.photo_outlined,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          )
                        : Image.asset(kListingFallbackAsset, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  top: AppSpacing.xs,
                  right: AppSpacing.xs,
                  child: HeartButton(listingId: listing.id),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: Text(
                    listing.title,
                    style: AppTypography.h3.copyWith(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                StarRating(
                  rating: listing.rating,
                  suffix: '${listing.reviewCount}',
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              listing.subtitle,
              style: AppTypography.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              l10n.distanceAway(listing.distanceFromHomeLabel(origin)),
              style: AppTypography.small,
            ),
            const SizedBox(height: 2),
            Text(
              listing.priceFromQar == 0
                  ? l10n.free
                  : l10n.fromPrice('${listing.priceFromQar}'),
              style: AppTypography.label,
            ),
          ],
        ),
      ),
    );
  }
}
