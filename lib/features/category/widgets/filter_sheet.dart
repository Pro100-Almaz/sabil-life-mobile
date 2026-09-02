import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/state/auth_provider.dart';
import '../../../core/state/filter_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/util/location_service.dart';
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
  late DistanceOrigin _distanceOrigin;
  bool _resolvingLocation = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    final filter = ref.read(filterProvider);
    _maxDistanceKm = filter.maxDistanceKm;
    _priceMax = filter.priceMax;
    _ageGroup = filter.ageGroup;
    _distanceOrigin = filter.distanceOrigin;
  }

  String _messageForLocationError(Object error) {
    final l10n = AppLocalizations.of(context)!;
    if (error is LocationFailure) {
      return switch (error.reason) {
        LocationFailureReason.servicesDisabled => l10n.locationServicesDisabled,
        LocationFailureReason.permissionDenied => l10n.locationPermissionDenied,
        LocationFailureReason.unavailable => l10n.locationUnavailable,
      };
    }
    return l10n.locationUnavailable;
  }

  Future<void> _apply() async {
    final l10n = AppLocalizations.of(context)!;
    LatLng? origin;

    if (_distanceOrigin == DistanceOrigin.home) {
      origin = ref.read(authProvider).user?.homeLocation;
      if (origin == null) {
        setState(() => _locationError = l10n.homeLocationRequired);
        return;
      }
    } else {
      setState(() {
        _resolvingLocation = true;
        _locationError = null;
      });
      try {
        origin = await ref.read(locationServiceProvider).getUserLocation();
      } catch (error) {
        if (mounted) {
          setState(() {
            _resolvingLocation = false;
            _locationError = _messageForLocationError(error);
          });
        }
        return;
      }
    }

    if (!mounted) return;
    ref
        .read(filterProvider.notifier)
        .applyFilters(
          maxDistanceKm: _maxDistanceKm,
          priceMax: _priceMax,
          ageGroup: _ageGroup,
          userPosition: origin,
          distanceOrigin: _distanceOrigin,
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: SingleChildScrollView(
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
              const SizedBox(height: AppSpacing.md),
              Text(l10n.distanceFrom, style: AppTypography.label),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<DistanceOrigin>(
                  segments: [
                    ButtonSegment(
                      value: DistanceOrigin.home,
                      icon: const Icon(Icons.home_outlined),
                      label: Text(l10n.home),
                    ),
                    ButtonSegment(
                      value: DistanceOrigin.currentLocation,
                      icon: const Icon(Icons.my_location),
                      label: Text(l10n.currentLocation),
                    ),
                  ],
                  selected: {_distanceOrigin},
                  onSelectionChanged: _resolvingLocation
                      ? null
                      : (selection) => setState(() {
                          _distanceOrigin = selection.single;
                          _locationError = null;
                        }),
                ),
              ),
              if (_locationError != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _locationError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
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
                    child: _resolvingLocation
                        ? const Center(child: CircularProgressIndicator())
                        : AppButton(label: l10n.apply, onPressed: _apply),
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
