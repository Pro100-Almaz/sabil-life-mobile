import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/util/tutor_label.dart';
import '../../../data/mock/mock_listings.dart';
import '../../../data/models/tutor.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/star_rating.dart';

Future<void> showTutorProfileSheet(BuildContext context, Tutor tutor) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.sheet),
      ),
    ),
    builder: (context) => TutorProfileSheet(tutor: tutor),
  );
}

/// Light tutor detail: profile sheet with credentials, formats, languages
/// and a link to the tutor's centre listing.
class TutorProfileSheet extends StatelessWidget {
  const TutorProfileSheet({super.key, required this.tutor});

  final Tutor tutor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final centre = listingById(tutor.affiliationListingId);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: tutor.avatarUrl,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 72,
                      height: 72,
                      color: AppColors.surfaceAlt,
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 72,
                      height: 72,
                      color: AppColors.surfaceAlt,
                      child: const Icon(
                        Icons.person_outline,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tutor.name, style: AppTypography.h2),
                      const SizedBox(height: 2),
                      StarRating(
                        rating: tutor.rating,
                        suffix: l10n.reviews(tutor.reviewCount),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.yearsExperience(tutor.yearsExperience),
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(tutor.credentials, style: AppTypography.label),
            if (centre != null) ...[
              const SizedBox(height: 2),
              Text(centre.title, style: AppTypography.caption),
            ],
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final subject in tutor.subjects)
                  _Tag(label: subject.label(l10n), filled: true),
                for (final format in tutor.formats)
                  _Tag(label: format.label(l10n)),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '${l10n.languagesLabel}: ${tutor.languages.join(", ")}',
              style: AppTypography.caption,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(tutor.bio, style: AppTypography.body.copyWith(height: 1.5)),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Text(
                  l10n.perHour('${tutor.pricePerHourQar}'),
                  style: AppTypography.h3,
                ),
                const Spacer(),
                if (tutor.trialAvailable)
                  Text(
                    l10n.trialLesson,
                    style: AppTypography.label.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            if (centre != null)
              AppButton(
                label: l10n.viewCentre,
                expanded: true,
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push('/listing/${centre.id}');
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, this.filled = false});

  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: filled ? AppColors.surfaceAlt : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.chip),
        border: Border.all(
          color: filled ? Colors.transparent : AppColors.border,
        ),
      ),
      child: Text(label, style: AppTypography.small),
    );
  }
}
