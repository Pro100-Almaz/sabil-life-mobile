import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../models/city.dart';

/// Loads the bundled city list from assets and searches it client-side.
///
/// The list ships with the app (no network) — currently Qatar only, but the
/// [City] model already carries a country code so other countries can be added
/// to the JSON later without code changes.
class CityRepository {
  CityRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  static const _assetPath = 'assets/data/qatar_cities.json';

  final AssetBundle _bundle;
  List<City>? _cache;

  /// All cities, loaded once and cached for the session.
  Future<List<City>> all() async {
    final cached = _cache;
    if (cached != null) return cached;
    final raw = await _bundle.loadString(_assetPath);
    final cities = (jsonDecode(raw) as List)
        .map((e) => City.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    _cache = cities;
    return cities;
  }

  /// Cities whose name in [languageCode] contains [query] (case-insensitive).
  /// An empty query returns the full list (capped to [limit]).
  Future<List<City>> search(
    String query,
    String languageCode, {
    int limit = 8,
  }) async {
    final cities = await all();
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return cities.take(limit).toList();
    return cities
        .where((c) => c.localizedName(languageCode).toLowerCase().contains(q))
        .take(limit)
        .toList();
  }

  /// Resolves a stored backend value (`"Doha, QA"`) back to its [City].
  Future<City?> byBackendValue(String value) async {
    if (value.isEmpty) return null;
    final cities = await all();
    for (final c in cities) {
      if (c.backendValue == value) return c;
    }
    return null;
  }
}
