import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/util/location_service.dart';
import '../../../data/mock/mock_home.dart';

/// Tap-to-pick location map for the listing editor. Reports the chosen
/// coordinate to the parent via [onLocationPicked]; holds its own marker state.
class ListingLocationMap extends ConsumerStatefulWidget {
  const ListingLocationMap({
    super.key,
    required this.initialLocation,
    required this.onLocationPicked,
  });

  final LatLng initialLocation;
  final ValueChanged<LatLng> onLocationPicked;

  @override
  ConsumerState<ListingLocationMap> createState() => _ListingLocationMapState();
}

class _ListingLocationMapState extends ConsumerState<ListingLocationMap> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  late LatLng _picked = widget.initialLocation;
  LatLng userLocation = mockHome;
  
  void _onTap(LatLng point) {
    setState(() => _picked = point);
    widget.onLocationPicked(point);
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
      setState(() {
        userLocation = position;
        _picked = position;
      });
      _mapController.move(userLocation, 14);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not get your location')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: SizedBox(
        height: 200,
        
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: widget.initialLocation,
                initialZoom: 15,
                onTap: (tapPosition, point) => _onTap(point),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'io.sabil.sabil_life',
                ),
                MarkerLayer(
                  rotate: true,
                  markers: [
                    Marker(
                      point: _picked,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.place,
                        size: 36,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            AnimatedPositioned(
              right: AppSpacing.lg,
              bottom: AppSpacing.lg,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton.small(
                    onPressed: _mapRotationReset,
                    heroTag: 'rotation_reset',
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.primaryPressed,
                    elevation: 2,
                    child: const Icon(Icons.compass_calibration, size: 20),
                  ),
                  FloatingActionButton.small(
                    onPressed: _goToUserLocation,
                    heroTag: 'user_location',
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.primaryPressed,
                    child: const Icon(Icons.my_location, size: 20),
                  ),
                ]
              )
            )
          ]
        ) 
      ),
    );
  }
}
