import 'dart:math' as math;

import '../../data/mock/mock_home.dart';
import '../../data/models/listing.dart';

const double _earthRadiusKm = 6371.0;

/// Haversine distance in kilometres between two coordinates.
double haversineKm(double lat1, double lng1, double lat2, double lng2) {
  final dLat = _degToRad(lat2 - lat1);
  final dLng = _degToRad(lng2 - lng1);
  final a =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(_degToRad(lat1)) *
          math.cos(_degToRad(lat2)) *
          math.pow(math.sin(dLng / 2), 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return _earthRadiusKm * c;
}

double _degToRad(double deg) => deg * math.pi / 180;

/// Distance from the mock family home, formatted to one decimal.
String formatKm(double km) => km.toStringAsFixed(1);

extension ListingDistance on Listing {
  double get distanceFromHomeKm =>
      haversineKm(mockHomeLat, mockHomeLng, lat, lng);

  String get distanceFromHomeLabel => formatKm(distanceFromHomeKm);
}
