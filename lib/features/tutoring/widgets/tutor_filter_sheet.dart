import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/state/filter_provider.dart' show kAgeGroups;
import '../../../core/state/tutor_filter_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/util/tutor_label.dart';
import '../../../data/models/tutor.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/city_autocomplete_field.dart';
import '../../../shared/widgets/pill_chip.dart';

Future<void> showTutorFilterSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.sheet),
      ),
    ),
    builder: (context) => const TutorFilterSheet(),
  );
}

class TutorFilterSheet extends ConsumerStatefulWidget {
  const TutorFilterSheet({super.key});

  @override
  ConsumerState<TutorFilterSheet> createState() => _TutorFilterSheetState();
}

class _TutorFilterSheetState extends ConsumerState<TutorFilterSheet> {
  late Set<TutorFormat> _formats;
  late Set<String> _ageGroups;
  late Set<String> _languages;
  late bool _trialOnly;
  late String? _city;
  late final TextEditingController _priceMin;
  late final TextEditingController _priceMax;

  @override
  void initState() {
    super.initState();
    final filter = ref.read(tutorFilterProvider);
    _formats = Set.of(filter.formats);
    _ageGroups = Set.of(filter.ageGroups);
    _languages = Set.of(filter.languages);
    _trialOnly = filter.trialOnly;
    _city = filter.city;
    _priceMin = TextEditingController(text: filter.priceMin?.toString() ?? '');
    _priceMax = TextEditingController(text: filter.priceMax?.toString() ?? '');
  }

  @override
  void dispose() {
    _priceMin.dispose();
    _priceMax.dispose();
    super.dispose();
  }

  void _toggle<T>(Set<T> set, T value) =>
      setState(() => set.contains(value) ? set.remove(value) : set.add(value));

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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.filters, style: AppTypography.h2),
              const SizedBox(height: AppSpacing.xxl),

              // Format
              Text(l10n.profileFormats, style: AppTypography.h3),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final format in TutorFormat.values)
                    PillChip(
                      label: format.label(l10n),
                      selected: _formats.contains(format),
                      onTap: () => _toggle(_formats, format),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Age groups
              Text(l10n.profileAgeGroups, style: AppTypography.h3),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final age in kAgeGroups)
                    PillChip(
                      label: age,
                      selected: _ageGroups.contains(age),
                      onTap: () => _toggle(_ageGroups, age),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Languages
              Text(l10n.profileLanguages, style: AppTypography.h3),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final lang in kTutorLanguages)
                    PillChip(
                      label: lang,
                      selected: _languages.contains(lang),
                      onTap: () => _toggle(_languages, lang),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // City
              CityAutocompleteField(
                initialBackendValue: _city,
                onChanged: (city) => setState(() => _city = city?.backendValue),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Price range
              Text(l10n.priceRange, style: AppTypography.h3),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _PriceField(
                      controller: _priceMin,
                      label: l10n.priceMin,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _PriceField(
                      controller: _priceMax,
                      label: l10n.priceMax,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Trial lesson
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.primary,
                title: Text(l10n.filterTrialOnly, style: AppTypography.body),
                value: _trialOnly,
                onChanged: (value) => setState(() => _trialOnly = value),
              ),
              const SizedBox(height: AppSpacing.xxl),

              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: l10n.reset,
                      variant: AppButtonVariant.outlined,
                      onPressed: () {
                        ref.read(tutorFilterProvider.notifier).resetFilters();
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
                            .read(tutorFilterProvider.notifier)
                            .applyFilters(
                              formats: _formats,
                              ageGroups: _ageGroups,
                              languages: _languages,
                              priceMin: int.tryParse(_priceMin.text.trim()),
                              priceMax: int.tryParse(_priceMax.text.trim()),
                              trialOnly: _trialOnly,
                              city: _city,
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
      ),
    );
  }
}

class _PriceField extends StatelessWidget {
  const _PriceField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: AppTypography.body,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
      ),
    );
  }
}
