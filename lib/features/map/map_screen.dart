import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/state/filter_provider.dart';
import '../../core/state/provider_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/util/category_label.dart';
import '../../core/util/location_service.dart';
import '../../data/mock/mock_home.dart';
import '../../data/models/listing.dart';
import '../../shared/widgets/pill_chip.dart';
import 'widgets/map_listing_preview.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key, this.focusListingId});

  final String? focusListingId;

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  LatLng userLocation = mockHome;
  LatLng pickLocaton = mockHome;

  String? _selectedId;
  bool _showCategory = false;
  bool _showBurger = true;

  /// Listings behind a tapped cluster, shown as a swipeable carousel.
  List<Listing> _clusterListings = const [];
  int _carouselIndex = 0;
  final PageController _carouselController = PageController(
    viewportFraction: 0.88,
  );

  @override
  void initState() {
    super.initState();
    _selectedId = widget.focusListingId;
  }

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  void _clearCluster() {
    if (_clusterListings.isEmpty) return;
    setState(() {
      _clusterListings = const [];
      _carouselIndex = 0;
    });
  }

  void _onClusterTapped(MarkerClusterNode node, List<Listing> listings) {
    final ids = node.mapMarkers
        .map((m) => m.key)
        .whereType<ValueKey<String>>()
        .map((k) => k.value)
        .toSet();
    final selected = listings.where((l) => ids.contains(l.id)).toList();
    if (selected.isEmpty) return;
    setState(() {
      _selectedId = null;
      _carouselIndex = 0;
      _clusterListings = selected;
    });
    if (_carouselController.hasClients) {
      _carouselController.jumpToPage(0);
    }
  }

  void _burgerPressed() {
    setState(() {
      _showBurger = !_showBurger;
      _showCategory = !_showBurger;
    });
  }

  void _mapRotationReset() {
    final currentRotation = _mapController.camera.rotation;
    if (currentRotation == 0) return;

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    final animation = Tween<double>(
      begin: currentRotation,
      end: 0.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    animation.addListener(() => _mapController.rotate(animation.value));

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) controller.dispose();
    });

    controller.forward();
  }

  Future<void> _goToUserLocation() async {
    try {
      final position = await ref
          .read(locationServiceProvider)
          .getUserLocation();
      if (!mounted) return;
      setState(() => userLocation = position);
      _mapController.move(userLocation, 14);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not get your location')),
      );
    }
  }

  void _markerOnLatLen(LatLng coordinates) {
    setState(() => pickLocaton = coordinates);
    _mapController.move(coordinates, 17);
  }

  @override
  void didUpdateWidget(covariant MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusListingId != null &&
        widget.focusListingId != oldWidget.focusListingId) {
      _selectedId = widget.focusListingId;
      // Attempt to move the map — the focused listing may not be loaded yet;
      // the build will animate once catalogDetailProvider resolves.
      final focused = ref
          .read(catalogDetailProvider(widget.focusListingId!))
          .valueOrNull;
      if (focused != null) {
        _mapController.move(LatLng(focused.lat, focused.lng), 14);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final asyncListings = ref.watch(filteredListingsProvider);
    final selectedCategory = ref.watch(
      filterProvider.select((f) => f.selectedCategory),
    );

    // Resolve the focused listing from the catalog detail provider when set.
    final focusedAsync = _selectedId != null
        ? ref.watch(catalogDetailProvider(_selectedId!))
        : null;
    final focused = focusedAsync?.valueOrNull;

    final initialCenter = focused != null
        ? LatLng(focused.lat, focused.lng)
        : mockHome;

    // When a focus listing loads for the first time, move the map.
    if (focused != null && focusedAsync?.isLoading == false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.focusListingId == _selectedId) {
          _mapController.move(LatLng(focused.lat, focused.lng), 14);
        }
      });
    }
    final listings = asyncListings.valueOrNull ?? const [];
    final showCarousel = _clusterListings.isNotEmpty;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: focused != null ? 14 : 11.5,
              onTap: (tapPosition, point) {
                setState(() {
                  _selectedId = null;
                  _clusterListings = const [];
                  _carouselIndex = 0;
                  _markerOnLatLen(point);
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'io.sabil.sabil_life',
              ),
              // Fixed reference markers (pick / home / user) never cluster.
              MarkerLayer(
                rotate: true,
                markers: [
                  Marker(
                    point: pickLocaton,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.place,
                      size: 22,
                      color: Colors.purple,
                    ),
                  ),
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
                  Marker(
                    point: userLocation,
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.textPrimary,
                        shape: BoxShape.circle,
                        boxShadow: AppShadow.soft,
                      ),
                      child: const Icon(
                        Icons.beenhere_rounded,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              // Listing markers cluster together when zoomed out.
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  rotate: true,
                  maxClusterRadius: 45,
                  size: const Size(44, 44),
                  disableClusteringAtZoom: 16,
                  padding: const EdgeInsets.all(50),
                  zoomToBoundsOnClick: false,
                  onClusterTap: (node) => _onClusterTapped(node, listings),
                  markers: [
                    for (final listing in listings)
                      Marker(
                        key: ValueKey(listing.id),
                        point: LatLng(listing.lat, listing.lng),
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedId = listing.id;
                              _clusterListings = const [];
                              _carouselIndex = 0;
                            });
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
                  builder: (context, clusterMarkers) => Container(
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: AppShadow.soft,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${clusterMarkers.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SafeArea(
            child: AnimatedSlide(
              offset: _showCategory ? Offset.zero : Offset(0, -3),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: Container(
                height: 40,
                alignment: Alignment.centerLeft,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
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
          ),
          Positioned(
            top: 40,
            left: AppSpacing.lg,
            child: AnimatedSlide(
              offset: _showBurger ? Offset.zero : Offset(0, 1.0),
              duration: const Duration(milliseconds: 200),
              child: FloatingActionButton.small(
                onPressed: _burgerPressed,
                heroTag: 'map_burger',
                backgroundColor: _showBurger
                    ? AppColors.surface
                    : AppColors.primary,
                foregroundColor: _showBurger
                    ? AppColors.primaryPressed
                    : AppColors.surface,
                elevation: 2,
                child: _showBurger
                    ? const Icon(Icons.menu, size: 20)
                    : const Icon(Icons.arrow_upward, size: 20),
              ),
            ),
          ),
          AnimatedPositioned(
            right: AppSpacing.lg,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            bottom: (focused != null || showCarousel)
                ? AppSpacing.lg +
                      112 +
                      MediaQuery.of(context).padding.bottom +
                      AppSpacing.md
                : AppSpacing.lg,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  onPressed: _mapRotationReset,
                  heroTag: 'rotation_reset',
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.primaryPressed,
                  elevation: 2,
                  child: const Icon(Icons.compass_calibration, size: 20),
                ),
                const SizedBox(height: AppSpacing.lg),
                FloatingActionButton(
                  onPressed: _goToUserLocation,
                  heroTag: 'user_location',
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.primaryPressed,
                  child: const Icon(Icons.my_location, size: 20),
                ),
              ],
            ),
          ),
          // Loading indicator overlay while listings are fetching.
          if (asyncListings.isLoading)
            const Positioned(
              top: 72,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
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
          // Swipeable carousel of the listings inside a tapped cluster.
          if (showCarousel)
            Positioned(
              left: 0,
              right: 0,
              bottom: AppSpacing.lg,
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary,
                        borderRadius: BorderRadius.circular(AppRadius.chip),
                        boxShadow: AppShadow.soft,
                      ),
                      child: Text(
                        '${_carouselIndex + 1} / ${_clusterListings.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 112,
                      child: PageView.builder(
                        controller: _carouselController,
                        itemCount: _clusterListings.length,
                        onPageChanged: (i) {
                          final listing = _clusterListings[i];
                          setState(() => _carouselIndex = i);
                          _mapController.move(
                            LatLng(listing.lat, listing.lng),
                            _mapController.camera.zoom,
                          );
                        },
                        itemBuilder: (context, i) => Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                          child: MapListingPreview(
                            listing: _clusterListings[i],
                            onClose: _clearCluster,
                          ),
                        ),
                      ),
                    ),
                  ],
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
