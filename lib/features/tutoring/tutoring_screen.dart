import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/state/provider_providers.dart';
import '../../core/state/tutor_filter_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/util/tutor_label.dart';
import '../../data/repositories/tutor_repository.dart';
import '../../shared/widgets/app_refresh_indicator.dart';
import '../../shared/widgets/pill_chip.dart';
import 'widgets/tutor_card.dart';
import 'widgets/tutor_filter_sheet.dart';
import 'widgets/tutor_profile_sheet.dart';
import 'widgets/tutor_search_pill.dart';
import 'widgets/tutor_sort_menu.dart';

/// Dedicated, person-forward Tutoring page: subject rail, format filters
/// and tutor cards (instead of the generic venue directory).
class TutoringScreen extends ConsumerStatefulWidget {
  const TutoringScreen({super.key});

  @override
  ConsumerState<TutoringScreen> createState() => _TutoringScreenState();
}

class _TutoringScreenState extends ConsumerState<TutoringScreen> {
  bool _searchOptionsEnabled = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void enableSearchOptions() {
    setState(() => _searchOptionsEnabled = !_searchOptionsEnabled);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filter = ref.watch(tutorFilterProvider);
    final asyncTutors = ref.watch(filteredTutorsProvider);
    final asyncSubjects = ref.watch(availableSubjectsProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: SizedBox(height: 48, child: TutorSearchPill())),
            SizedBox(width: AppSpacing.sm),
            SizedBox.square(
              dimension: 48,
              child: IconButton(
                onPressed: enableSearchOptions,
                icon: const Icon(Icons.tune, size: 20),
              ),
            ),
            SizedBox(width: AppSpacing.md),
          ],
        ),
        // title: Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     Text(l10n.catTutoring, style: AppTypography.h3),
        //     asyncTutors.when(
        //       loading: () => Text(l10n.loading, style: AppTypography.small),
        //       error: (_, _) => const SizedBox.shrink(),
        //       data: (tutors) => Text(
        //         l10n.resultsCount(tutors.length),
        //         style: AppTypography.small,
        //       ),
        //     ),
        //   ],
        // ),
      ),
      body: Column(
        children: [
          SizedBox(height: AppSpacing.sm),
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
          SizedBox(height: _searchOptionsEnabled ? 0 : AppSpacing.sm),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: _searchOptionsEnabled
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        _ToolbarButton(
                          icon: Icons.tune,
                          label: l10n.filters,
                          highlighted: filter.hasActiveFilters,
                          onTap: () => showTutorFilterSheet(context),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _ToolbarButton(
                          icon: Icons.swap_vert,
                          label: l10n.sort,
                          highlighted: filter.sort != TutorSort.rating,
                          onTap: () => showTutorSortMenu(context),
                        ),
                      ],
                    ),
                  )
                : SizedBox(height: AppSpacing.sm),
          ),
          const Divider(),
          Expanded(
            child: AppRefreshIndicator(
              onRefresh: () => ref.refresh(
                tutorListProvider(ref.read(tutorsFilterProvider)).future,
              ),
              child: asyncTutors.when(
                loading: () => const RefreshableMessage(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (e, _) => RefreshableMessage(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l10n.genericLoadError, textAlign: TextAlign.center),
                      const SizedBox(height: AppSpacing.md),
                      TextButton(
                        onPressed: () => ref.invalidate(
                          tutorListProvider(ref.read(tutorsFilterProvider)),
                        ),
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
                data: (tutors) => tutors.isEmpty
                    ? RefreshableMessage(
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
                        physics: const AlwaysScrollableScrollPhysics(),
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
          ),
        ],
      ),
    );
  }
}

/// Filters / Sort toolbar button (mirrors the category list toolbar).
class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: Border.all(
            color: highlighted ? AppColors.textPrimary : AppColors.border,
            width: highlighted ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.textPrimary),
            const SizedBox(width: AppSpacing.xs),
            Text(label, style: AppTypography.label),
          ],
        ),
      ),
    );
  }
}
