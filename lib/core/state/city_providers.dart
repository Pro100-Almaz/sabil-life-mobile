import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/city.dart';
import '../../data/repositories/city_repository.dart';

/// Asset-backed city list repository (cached for the session).
final cityRepositoryProvider = Provider<CityRepository>(
  (ref) => CityRepository(),
);

/// The full bundled city list, loaded once.
final allCitiesProvider = FutureProvider<List<City>>(
  (ref) => ref.watch(cityRepositoryProvider).all(),
);
