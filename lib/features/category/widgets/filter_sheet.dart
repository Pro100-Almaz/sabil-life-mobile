import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/state/filter_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/pill_chip.dart';

Future<void> showFilterSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.sheet),
      ),
    ),
    builder: (context) => const FilterSheet(),
  );
}

class FilterSheet extends ConsumerStatefulWidget {
  const FilterSheet({super.key});

  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  late double _maxDistanceKm;
  late int _priceMax;
  late String? _ageGroup;

  @override
  void initState() {
    super.initState();
    final filter = ref.read(filterProvider);
    _maxDistanceKm = filter.maxDistanceKm;
    _priceMax = filter.priceMax;
    _ageGroup = filter.ageGroup;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.xxl,
          right: AppSpacing.xxl,
          top: AppSpacing.xxl,
          bottom: AppSpacing.xxl + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.filters, style: AppTypography.h2),
            const SizedBox(height: AppSpacing.xxl),
            Text(l10n.maxDistance, style: AppTypography.h3),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _maxDistanceKm,
                    min: 1,
                    max: kMaxDistanceCeilingKm,
                    divisions: 29,
                    onChanged: (value) =>
                        setState(() => _maxDistanceKm = value),
                  ),
                ),
                SizedBox(
                  width: 64,
                  child: Text(
                    l10n.kmUnit(_maxDistanceKm.toStringAsFixed(0)),
                    style: AppTypography.label,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.priceRange, style: AppTypography.h3),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _priceMax.toDouble(),
                    min: 0,
                    max: kPriceCeilingQar.toDouble(),
                    divisions: 50,
                    onChanged: (value) =>
                        setState(() => _priceMax = value.round()),
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: Text(
                    l10n.upToPrice('$_priceMax'),
                    style: AppTypography.label,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.ageGroup, style: AppTypography.h3),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                PillChip(
                  label: l10n.anyAge,
                  selected: _ageGroup == null,
                  onTap: () => setState(() => _ageGroup = null),
                ),
                for (final age in kAgeGroups)
                  PillChip(
                    label: age,
                    selected: _ageGroup == age,
                    onTap: () => setState(() => _ageGroup = age),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxxl),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: l10n.reset,
                    variant: AppButtonVariant.outlined,
                    onPressed: () {
                      ref.read(filterProvider.notifier).resetFilters();
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    label: l10n.apply,
                    onPressed: () {
                      ref
                          .read(filterProvider.notifier)
                          .applyFilters(
                            maxDistanceKm: _maxDistanceKm,
                            priceMax: _priceMax,
                            ageGroup: _ageGroup,
                          );
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
