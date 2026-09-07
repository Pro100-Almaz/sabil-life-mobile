import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

enum LocationFailureReason { servicesDisabled, permissionDenied, unavailable }

class LocationFailure implements Exception {
  const LocationFailure(this.reason);
  final LocationFailureReason reason;
}

class LocationService {
  Future<LatLng?> _lastKnownLocation() async {
    Position? position = await Geolocator.getLastKnownPosition();

    if (position != null) {
      return LatLng(position.latitude, position.longitude);
    } else {
      return null;
    }
  }

  Future<void> _ensureLocationAvailable() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationFailure(LocationFailureReason.servicesDisabled);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        throw const LocationFailure(LocationFailureReason.permissionDenied);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      throw const LocationFailure(LocationFailureReason.permissionDenied);
    }
  }

  Future<LatLng> getUserLocation() async {
    await _ensureLocationAvailable();
    try {
      final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );

      Position positionValue = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
      return LatLng(positionValue.latitude, positionValue.longitude);
    } catch (_) {
      final lastLocation = await _lastKnownLocation();
      if (lastLocation != null) return lastLocation;
      throw const LocationFailure(LocationFailureReason.unavailable);
    }
  }

  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  Future<bool> openAppSettings() => Geolocator.openAppSettings();
}

final locationServiceProvider = Provider((ref) => LocationService());
