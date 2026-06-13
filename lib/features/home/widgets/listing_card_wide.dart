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

/// Horizontal card variant: photo left, meta right. Used in dense lists
/// (e.g. Saved tab).
class ListingCardWide extends StatelessWidget {
  const ListingCardWide({super.key, required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () => context.push('/listing/${listing.id}'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                width: 130,
                height: 100,
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
                child: HeartButton(listingId: listing.id, size: 20),
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
                Text(
                  listing.subtitle,
                  style: AppTypography.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                StarRating(
                  rating: listing.rating,
                  suffix: l10n.reviews(listing.reviewCount),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.distanceAway(listing.distanceFromHomeLabel),
                  style: AppTypography.small,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
