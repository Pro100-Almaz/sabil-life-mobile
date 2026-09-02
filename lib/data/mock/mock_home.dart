import 'package:latlong2/latlong.dart';

/// A neutral center near The Pearl, Doha, used to initialize maps before the
/// user chooses a meaningful coordinate.
const double defaultDohaLat = 25.3690;
const double defaultDohaLng = 51.5510;

/// Neutral initial map center used before a real user-selected coordinate is
/// available. It must never be presented as the user's actual home/location.
const LatLng defaultDohaCenter = LatLng(defaultDohaLat, defaultDohaLng);

@Deprecated('Use defaultDohaCenter only for neutral map initialization.')
const LatLng mockHome = defaultDohaCenter;
