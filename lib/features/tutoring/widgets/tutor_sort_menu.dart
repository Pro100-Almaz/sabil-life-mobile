import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/state/tutor_filter_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/repositories/tutor_repository.dart';

Future<void> showTutorSortMenu(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.sheet),
      ),
    ),
    builder: (context) => const TutorSortMenu(),
  );
}

class TutorSortMenu extends ConsumerWidget {
  const TutorSortMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final current = ref.watch(tutorFilterProvider.select((f) => f.sort));

    String labelFor(TutorSort sort) => switch (sort) {
      TutorSort.rating => l10n.sortRating,
      TutorSort.priceLow => l10n.sortPriceLow,
      TutorSort.priceHigh => l10n.sortPriceHigh,
      TutorSort.experience => l10n.sortExperience,
      TutorSort.newest => l10n.sortNewest,
    };

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxl,
                vertical: AppSpacing.sm,
              ),
              child: Text(l10n.sort, style: AppTypography.h2),
            ),
            for (final sort in TutorSort.values)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                ),
                title: Text(labelFor(sort), style: AppTypography.body),
                trailing: current == sort
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  ref.read(tutorFilterProvider.notifier).setSort(sort);
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}
