import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/state/masterclass_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/heart_button.dart';
import '../../../shared/widgets/star_rating.dart';

/// Event-shaped masterclass card: photo with a date chip overlay, seats-left
/// scarcity badge, duration / age / participation meta.
class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.entry,
    this.window = DateWindow.all,
  });

  final MasterclassEntry entry;

  /// When a specific window is active, the card surfaces its first session
  /// inside that window rather than its overall next session.
  final DateWindow window;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final listing = entry.listing;
    final sessions = entry.upcomingSessions;
    final next = window == DateWindow.all
        ? sessions.first
        : sessions.firstWhere(
            (s) => windowFor(s.start) == window,
            orElse: () => sessions.first,
          );
    final dateLabel =
        '${DateFormat('EEE, d MMM', locale).format(next.start)} · '
        '${DateFormat('HH:mm', locale).format(next.start)}';

    return GestureDetector(
      onTap: () => context.push('/listing/${listing.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
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
                top: AppSpacing.md,
                left: AppSpacing.md,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs + 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                    boxShadow: AppShadow.soft,
                  ),
                  child: Text(dateLabel, style: AppTypography.small),
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
            '${l10n.durationMinutes(entry.info.durationMin)} · '
            '${listing.ageGroups.join(", ")} · '
            '${entry.info.parentAndChild ? l10n.withParent : l10n.dropOff}',
            style: AppTypography.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              if (next.seatsLeft <= 5) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                  ),
                  child: Text(
                    l10n.seatsLeft(next.seatsLeft),
                    style: AppTypography.small.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(
                entry.info.sessionsCount > 1
                    ? l10n.seriesCount(entry.info.sessionsCount)
                    : l10n.oneOffEvent,
                style: AppTypography.small,
              ),
              const Spacer(),
              Text(
                l10n.perSession('${listing.priceFromQar}'),
                style: AppTypography.label,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
