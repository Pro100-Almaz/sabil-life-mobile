import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/util/distance.dart';
import '../../../data/models/listing.dart';
import '../../../shared/widgets/heart_button.dart';
import '../../../shared/widgets/star_rating.dart';

/// Mini card shown at the bottom of the map when a marker is tapped.
/// Tapping it opens the listing detail.
class MapListingPreview extends StatelessWidget {
  const MapListingPreview({
    super.key,
    required this.listing,
    required this.onClose,
  });

  final Listing listing;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () => context.push('/listing/${listing.id}'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: AppShadow.soft,
        ),
        child: Row(
          children: [
            Stack(
              children: [
                SizedBox(
                  width: 96,
                  height: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.image),
                    child: CachedNetworkImage(
                      imageUrl: listing.imageUrls.first,
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
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: HeartButton(listingId: listing.id, size: 18),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    style: AppTypography.h3.copyWith(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  StarRating(
                    rating: listing.rating,
                    suffix: '${listing.reviewCount}',
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.distanceAway(listing.distanceFromHomeLabel),
                    style: AppTypography.small,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.close,
                size: 20,
                color: AppColors.textSecondary,
              ),
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }
}
