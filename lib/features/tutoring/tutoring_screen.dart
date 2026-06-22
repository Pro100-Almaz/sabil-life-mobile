import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/state/provider_providers.dart';
import '../../core/state/tutor_filter_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/util/tutor_label.dart';
import '../../data/models/tutor.dart';
import '../../shared/widgets/pill_chip.dart';
import 'widgets/tutor_card.dart';
import 'widgets/tutor_profile_sheet.dart';

/// Dedicated, person-forward Tutoring page: subject rail, format filters
/// and tutor cards (instead of the generic venue directory).
class TutoringScreen extends ConsumerWidget {
  const TutoringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final filter = ref.watch(tutorFilterProvider);
    final asyncTutors = ref.watch(filteredTutorsProvider);
    final asyncSubjects = ref.watch(availableSubjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.catTutoring, style: AppTypography.h3),
            asyncTutors.when(
              loading: () => Text(l10n.loading, style: AppTypography.small),
              error: (_, _) => const SizedBox.shrink(),
              data: (tutors) => Text(
                l10n.resultsCount(tutors.length),
                style: AppTypography.small,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 40,
            child: asyncSubjects.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (subjects) => ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                children: [
                  PillChip(
                    label: l10n.catAll,
                    selected: filter.subject == null,
                    onTap: () =>
                        ref.read(tutorFilterProvider.notifier).setSubject(null),
                  ),
                  for (final subject in subjects) ...[
                    const SizedBox(width: AppSpacing.sm),
                    PillChip(
                      label: subjectLabel(subject, l10n),
                      selected: filter.subject == subject,
                      onTap: () => ref
                          .read(tutorFilterProvider.notifier)
                          .setSubject(
                            filter.subject == subject ? null : subject,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final format in TutorFormat.values) ...[
                    _FormatChip(
                      label: format.label(l10n),
                      selected: filter.formats.contains(format),
                      onTap: () => ref
                          .read(tutorFilterProvider.notifier)
                          .toggleFormat(format),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                ],
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: asyncTutors.when(
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
                      onPressed: () => ref.invalidate(allTutorsProvider),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
              data: (tutors) => tutors.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 48,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(l10n.noResults, style: AppTypography.h3),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            l10n.noResultsHint,
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: tutors.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) => TutorCard(
                        tutor: tutors[index],
                        onTap: () =>
                            showTutorProfileSheet(context, tutors[index]),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Outlined multi-select toggle (distinct from the single-select PillChip).
class _FormatChip extends StatelessWidget {
  const _FormatChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: Border.all(
            color: selected ? AppColors.textPrimary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check, size: 14),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(label, style: AppTypography.small),
          ],
        ),
      ),
    );
  }
}
