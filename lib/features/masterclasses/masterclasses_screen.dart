import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/state/masterclass_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/pill_chip.dart';
import 'widgets/event_card.dart';

/// Dedicated, event-oriented Masterclasses page: date-window chips and
/// upcoming sessions grouped by "This weekend / Next week / Later".
class MasterclassesScreen extends ConsumerWidget {
  const MasterclassesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final window = ref.watch(dateWindowProvider);
    final entries = ref.watch(masterclassEntriesProvider);

    // With "All" active, group by each entry's next session; with a specific
    // window active, everything belongs to that one group.
    final groups = <DateWindow, List<MasterclassEntry>>{};
    for (final entry in entries) {
      final w = window == DateWindow.all
          ? windowFor(entry.upcomingSessions.first.start)
          : window;
      groups.putIfAbsent(w, () => []).add(entry);
    }

    String groupTitle(DateWindow w) => switch (w) {
      DateWindow.thisWeekend => l10n.thisWeekend,
      DateWindow.nextWeek => l10n.nextWeek,
      // Under "All", entries whose next session is beyond next week.
      DateWindow.all => l10n.later,
    };

    final orderedGroups = [
      DateWindow.thisWeekend,
      DateWindow.nextWeek,
      DateWindow.all,
    ].where(groups.containsKey).toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.catMasterclasses, style: AppTypography.h3),
            Text(l10n.resultsCount(entries.length), style: AppTypography.small),
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              children: [
                PillChip(
                  label: l10n.catAll,
                  selected: window == DateWindow.all,
                  onTap: () => ref.read(dateWindowProvider.notifier).state =
                      DateWindow.all,
                ),
                const SizedBox(width: AppSpacing.sm),
                PillChip(
                  label: l10n.thisWeekend,
                  selected: window == DateWindow.thisWeekend,
                  onTap: () => ref.read(dateWindowProvider.notifier).state =
                      DateWindow.thisWeekend,
                ),
                const SizedBox(width: AppSpacing.sm),
                PillChip(
                  label: l10n.nextWeek,
                  selected: window == DateWindow.nextWeek,
                  onTap: () => ref.read(dateWindowProvider.notifier).state =
                      DateWindow.nextWeek,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(),
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.event_busy,
                          size: 48,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(l10n.noResults, style: AppTypography.h3),
                        const SizedBox(height: AppSpacing.xs),
                        Text(l10n.noResultsHint, style: AppTypography.caption),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    children: [
                      for (final w in orderedGroups) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: Text(groupTitle(w), style: AppTypography.h2),
                        ),
                        for (final entry in groups[w]!) ...[
                          EventCard(entry: entry, window: window),
                          const SizedBox(height: AppSpacing.xxl),
                        ],
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
