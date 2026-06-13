import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/state/filter_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/util/category_label.dart';
import '../../../data/models/listing.dart';
import '../../../shared/widgets/pill_chip.dart';

/// Horizontal strip of selectable category chips. "All" resets the category
/// and stays on Home; a single category tap navigates to its list screen.
class CategoryStrip extends ConsumerWidget {
  const CategoryStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selected = ref.watch(
      filterProvider.select((f) => f.selectedCategory),
    );

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        children: [
          PillChip(
            label: l10n.catAll,
            selected: selected == null,
            onTap: () => ref.read(filterProvider.notifier).setCategory(null),
          ),
          for (final category in CategoryType.values) ...[
            const SizedBox(width: AppSpacing.sm),
            PillChip(
              label: category.label(l10n),
              selected: selected == category,
              onTap: () {
                ref.read(filterProvider.notifier).setCategory(category);
                context.push(switch (category) {
                  CategoryType.tutoring => '/tutoring',
                  CategoryType.masterclasses => '/masterclasses',
                  _ => '/category/${category.name}',
                });
              },
            ),
          ],
        ],
      ),
    );
  }
}
