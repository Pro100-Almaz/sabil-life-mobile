import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/state/filter_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/util/category_label.dart';
import '../../data/mock/mock_home.dart';
import '../../data/mock/mock_listings.dart';
import '../../data/models/listing.dart';
import '../../shared/widgets/pill_chip.dart';
import 'widgets/map_listing_preview.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key, this.focusListingId});

  /// When set (e.g. via "View on map" on a detail screen), the map opens
  /// centered on this listing with its preview card shown.
  final String? focusListingId;

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.focusListingId;
  }

  @override
  void didUpdateWidget(covariant MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusListingId != null &&
        widget.focusListingId != oldWidget.focusListingId) {
      _selectedId = widget.focusListingId;
      final listing = listingById(widget.focusListingId!);
      if (listing != null) {
        _mapController.move(LatLng(listing.lat, listing.lng), 14);
      }
    }
  }

  Listing? get _selectedListing =>
      _selectedId == null ? null : listingById(_selectedId!);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final listings = ref.watch(filteredListingsProvider);
    final selectedCategory = ref.watch(
      filterProvider.select((f) => f.selectedCategory),
    );

    final focused = _selectedListing;
    final initialCenter = focused != null
        ? LatLng(focused.lat, focused.lng)
        : mockHome;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: focused != null ? 14 : 11.5,
              onTap: (tapPosition, point) => setState(() => _selectedId = null),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'io.sabil.sabil_life',
              ),
              MarkerLayer(
                markers: [
                  // Distinct home marker.
                  Marker(
                    point: mockHome,
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.textPrimary,
                        shape: BoxShape.circle,
                        boxShadow: AppShadow.soft,
                      ),
                      child: const Icon(
                        Icons.home,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  for (final listing in listings)
                    Marker(
                      point: LatLng(listing.lat, listing.lng),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedId = listing.id);
                          _mapController.move(
                            LatLng(listing.lat, listing.lng),
                            13.5,
                          );
                        },
                        child: Icon(
                          Icons.place,
                          size: listing.id == _selectedId ? 44 : 36,
                          color: listing.id == _selectedId
                              ? AppColors.primaryPressed
                              : AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          SafeArea(
            child: Container(
              height: 56,
              alignment: Alignment.centerLeft,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                children: [
                  _shadowed(
                    PillChip(
                      label: l10n.catAll,
                      selected: selectedCategory == null,
                      onTap: () =>
                          ref.read(filterProvider.notifier).setCategory(null),
                    ),
                  ),
                  for (final category in CategoryType.values) ...[
                    const SizedBox(width: AppSpacing.sm),
                    _shadowed(
                      PillChip(
                        label: category.label(l10n),
                        selected: selectedCategory == category,
                        onTap: () => ref
                            .read(filterProvider.notifier)
                            .setCategory(category),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (focused != null)
            Positioned(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: AppSpacing.lg,
              child: SafeArea(
                child: MapListingPreview(
                  listing: focused,
                  onClose: () => setState(() => _selectedId = null),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _shadowed(Widget child) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(AppRadius.chip),
      boxShadow: AppShadow.soft,
    ),
    child: child,
  );
}
