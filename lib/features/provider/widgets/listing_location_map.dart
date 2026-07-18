import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Tap-to-pick location map for the listing editor. Reports the chosen
/// coordinate to the parent via [onLocationPicked]; holds its own marker state.
class ListingLocationMap extends StatefulWidget {
  const ListingLocationMap({
    super.key,
    required this.initialLocation,
    required this.onLocationPicked,
  });

  final LatLng initialLocation;
  final ValueChanged<LatLng> onLocationPicked;

  @override
  State<ListingLocationMap> createState() => _ListingLocationMapState();
}

class _ListingLocationMapState extends State<ListingLocationMap> {
  final MapController _mapController = MapController();
  late LatLng _picked = widget.initialLocation;

  void _onTap(LatLng point) {
    setState(() => _picked = point);
    widget.onLocationPicked(point);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: SizedBox(
        height: 200,
        child: FlutterMap(
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
      ),
    );
  }
}
