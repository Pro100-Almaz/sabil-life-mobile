import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/state/auth_provider.dart';
import '../../core/state/filter_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/util/location_service.dart';
import '../../data/api/api_config.dart';
import '../../data/mock/mock_home.dart';
import '../../shared/widgets/app_button.dart';

class HomeLocationScreen extends ConsumerStatefulWidget {
  const HomeLocationScreen({super.key});

  @override
  ConsumerState<HomeLocationScreen> createState() => _HomeLocationScreenState();
}

class _HomeLocationScreenState extends ConsumerState<HomeLocationScreen> {
  final _mapController = MapController();
  late LatLng _selected;
  bool _locating = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selected = ref.read(authProvider).user?.homeLocation ?? defaultDohaCenter;
  }

  String _locationError(Object error) {
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

  Future<void> _useCurrentLocation() async {
    setState(() {
      _locating = true;
      _error = null;
    });
    try {
      final location = await ref
          .read(locationServiceProvider)
          .getUserLocation();
      if (!mounted) return;
      setState(() => _selected = location);
      _mapController.move(location, 15);
    } catch (error) {
      if (mounted) setState(() => _error = _locationError(error));
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final error = await ref
        .read(authProvider.notifier)
        .updateHomeLocation(
          latitude: _selected.latitude,
          longitude: _selected.longitude,
        );
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _saving = false;
        _error = error;
      });
      return;
    }

    final filter = ref.read(filterProvider);
    if (filter.distanceOrigin == DistanceOrigin.home) {
      ref
          .read(filterProvider.notifier)
          .updateOrigin(_selected, DistanceOrigin.home);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.homeLocationSaved)),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final busy = _locating || _saving;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeLocation)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(l10n.tapMapToSelectHome),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selected,
                initialZoom: 13,
                onTap: (_, point) => setState(() {
                  _selected = point;
                  _error = null;
                }),
              ),
              children: [
                TileLayer(
                  urlTemplate: mapTileUrlTemplate,
                  userAgentPackageName: 'io.sabilLife.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selected,
                      width: 48,
                      height: 48,
                      child: const Icon(
                        Icons.home,
                        size: 36,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null) ...[
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                OutlinedButton.icon(
                  onPressed: busy ? null : _useCurrentLocation,
                  icon: _locating
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location),
                  label: Text(l10n.useCurrentLocation),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (_saving)
                  const Center(child: CircularProgressIndicator())
                else if (!_locating)
                  AppButton(
                    label: l10n.saveHomeLocation,
                    expanded: true,
                    onPressed: _save,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
