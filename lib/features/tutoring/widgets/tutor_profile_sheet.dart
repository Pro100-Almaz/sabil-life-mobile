import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/state/city_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/util/tutor_label.dart';
import '../../../data/mock/mock_listings.dart';
import '../../../data/models/tutor.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/star_rating.dart';
import 'tutor_inquire_cta.dart';

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
class TutorProfileSheet extends ConsumerWidget {
  const TutorProfileSheet({super.key, required this.tutor});

  final Tutor tutor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final centre = listingById(tutor.affiliationListingId);

    final hasTags = tutor.subjects.isNotEmpty || tutor.formats.isNotEmpty;
    final hasCredentials = tutor.credentials.trim().isNotEmpty;
    final hasLanguages = tutor.languages.isNotEmpty;
    final hasCity = tutor.city.trim().isNotEmpty;
    final hasBio = tutor.bio.trim().isNotEmpty;
    final hasFacts =
        hasCredentials || hasLanguages || hasCity || centre != null;

    // Resolve the canonical city value (e.g. "Doha, QA") to its name in the
    // current app language, falling back to the raw value if not in the list.
    String cityDisplay = tutor.city;
    if (hasCity) {
      final cities = ref.watch(allCitiesProvider).value ?? const [];
      final lang = Localizations.localeOf(context).languageCode;
      final matches = cities.where((c) => c.backendValue == tutor.city);
      if (matches.isNotEmpty) cityDisplay = matches.first.localizedName(lang);
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          AppSpacing.md,
          AppSpacing.xxl,
          AppSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle.
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: tutor.avatarDisplayUrl,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const _AvatarFallback(),
                    errorWidget: (context, url, error) =>
                        const _AvatarFallback(),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tutor.name, style: AppTypography.h2),
                      const SizedBox(height: 4),
                      StarRating(
                        rating: tutor.rating,
                        suffix: l10n.reviews(tutor.reviewCount),
                      ),
                      if (tutor.yearsExperience > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          l10n.yearsExperience(tutor.yearsExperience),
                          style: AppTypography.caption,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            // Subjects + formats chips.
            if (hasTags) ...[
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final subject in tutor.subjects)
                    _Tag(label: subjectLabel(subject, l10n), filled: true),
                  for (final format in tutor.formats)
                    _Tag(label: format.label(l10n)),
                ],
              ),
            ],

            // Facts (only the ones we actually have).
            if (hasFacts) ...[
              const SizedBox(height: AppSpacing.lg),
              if (hasCredentials)
                _InfoRow(
                  icon: Icons.school_outlined,
                  label: l10n.qualifications,
                  value: tutor.credentials,
                ),
              if (hasLanguages)
                _InfoRow(
                  icon: Icons.language_outlined,
                  label: l10n.languagesLabel,
                  value: tutor.languages.join(', '),
                ),
              if (hasCity)
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  label: l10n.cityLabel,
                  value: cityDisplay,
                ),
              if (centre != null)
                _InfoRow(
                  icon: Icons.business_outlined,
                  label: l10n.centre,
                  value: centre.title,
                ),
            ],

            // About / bio.
            if (hasBio) ...[
              const SizedBox(height: AppSpacing.xl),
              Text(l10n.about, style: AppTypography.h3),
              const SizedBox(height: AppSpacing.sm),
              Text(tutor.bio, style: AppTypography.body.copyWith(height: 1.5)),
            ],

            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Text(
                  l10n.perHour('${tutor.pricePerHourQar}'),
                  style: AppTypography.h3,
                ),
                const Spacer(),
                if (tutor.trialAvailable)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                    ),
                    child: Text(
                      l10n.trialLesson,
                      style: AppTypography.label.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            TutorInquireCta(tutor: tutor),
            if (centre != null) ...[
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: l10n.viewCentre,
                variant: AppButtonVariant.outlined,
                expanded: true,
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push('/listing/${centre.id}');
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      color: AppColors.surfaceAlt,
      child: const Icon(Icons.person_outline, color: AppColors.textTertiary),
    );
  }
}

/// A labelled fact row: leading icon, a small grey label, and the value beneath.
/// Only rendered by the caller when the value is present.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.small),
                const SizedBox(height: 1),
                Text(value, style: AppTypography.label),
              ],
            ),
          ),
        ],
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
