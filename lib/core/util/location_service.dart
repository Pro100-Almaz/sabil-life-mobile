import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../data/mock/mock_home.dart';

class LocationService {
  Future<LatLng?> _lastKnownLocation() async {
    Position? position = await Geolocator.getLastKnownPosition();

    if (position != null) {
      return LatLng(position.latitude, position.longitude);
    } else {
      return null;
    }
  }

  Future<bool> _checkGeolocationEnabled() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error("Geolocation disabled");
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error("Permission for geolocation denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error("Permission for geolocation denied");
    }

    return true;
  }

  Future<LatLng> getUserLocation() async {
    LatLng position;
    if (await _checkGeolocationEnabled()) {
      final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );

      Position positionValue = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
      position = LatLng(positionValue.latitude, positionValue.longitude);
    } else {
      LatLng? lastLocation = await _lastKnownLocation();
      if (lastLocation != null) {
        position = lastLocation;
      } else {
        position = mockHome;
      }
    }
    return position;
  }
}

final locationServiceProvider = Provider((ref) => LocationService());
