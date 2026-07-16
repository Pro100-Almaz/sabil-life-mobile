import '../mock/mock_listings.dart';
import '../models/listing.dart';
import '../../core/util/distance.dart';

// ── Enums & value objects ────────────────────────────────────────────────────

enum ListingSort {
  distance,
  rating,
  priceLow;

  /// The key the backend expects in the `sort` query parameter.
  String get backendKey => switch (this) {
    ListingSort.distance => 'distance',
    ListingSort.rating => 'rating',
    ListingSort.priceLow => 'price_low',
  };
}

class CategoryCount {
  const CategoryCount({required this.key, required this.count});

  final CategoryType key;
  final int count;
}

/// Immutable filter bag used as the family key for [catalogListingsProvider].
class ListingsFilter {
  const ListingsFilter({
    this.category,
    this.query,
    this.tag,
    this.priceMax,
    this.ageGroup,
    this.lat,
    this.lng,
    this.maxDistanceKm,
    this.sort,
    this.page = 1,
  });

  final CategoryType? category;
  final String? query;

  /// Category-scoped tag pill selection. null = all tags.
  final String? tag;
  final int? priceMax;
  final String? ageGroup;
  final double? lat;
  final double? lng;
  final double? maxDistanceKm;
  final ListingSort? sort;
  final int page;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ListingsFilter &&
        other.category == category &&
        other.query == query &&
        other.tag == tag &&
        other.priceMax == priceMax &&
        other.ageGroup == ageGroup &&
        other.lat == lat &&
        other.lng == lng &&
        other.maxDistanceKm == maxDistanceKm &&
        other.sort == sort &&
        other.page == page;
  }

  @override
  int get hashCode => Object.hash(
    category,
    query,
    tag,
    priceMax,
    ageGroup,
    lat,
    lng,
    maxDistanceKm,
    sort,
    page,
  );
}

// ── Exception ────────────────────────────────────────────────────────────────

class CatalogException implements Exception {
  const CatalogException(this.message);
  final String message;

  @override
  String toString() => 'CatalogException: $message';
}

// ── Abstract contract ────────────────────────────────────────────────────────

abstract class CatalogRepository {
  Future<List<Listing>> listings({
    CategoryType? category,
    String? query,
    String? tag,
    int? priceMax,
    String? ageGroup,
    double? lat,
    double? lng,
    double? maxDistanceKm,
    ListingSort? sort,
    int page = 1,
  });

  Future<Listing> listing(String id);

  Future<List<CategoryCount>> categories();

  /// The distinct tags available within [category] (the backend category key,
  /// e.g. `SCHOOLS`; empty string = across all categories). Feeds the tag-pill
  /// rail on the category screen.
  Future<List<String>> tags(String category);
}

// ── Mock implementation ──────────────────────────────────────────────────────

class MockCatalogRepository implements CatalogRepository {
  static const Duration _latency = Duration(milliseconds: 300);

  @override
  Future<List<Listing>> listings({
    CategoryType? category,
    String? query,
    String? tag,
    int? priceMax,
    String? ageGroup,
    double? lat,
    double? lng,
    double? maxDistanceKm,
    ListingSort? sort,
    int page = 1,
  }) async {
    await Future<void>.delayed(_latency);
    try {
      final q = query?.trim().toLowerCase() ?? '';

      var result = mockListings.where((l) {
        if (l.status != ListingStatus.active) return false;
        if (category != null && l.category != category) return false;
        if (q.isNotEmpty) {
          final haystack = '${l.title} ${l.subtitle} ${l.neighborhood}'
              .toLowerCase();
          if (!haystack.contains(q)) return false;
        }
        if (tag != null && !l.tags.contains(tag)) return false;
        if (priceMax != null && l.priceFromQar > priceMax) return false;
        if (ageGroup != null && !l.ageGroups.contains(ageGroup)) return false;
        if (maxDistanceKm != null && l.distanceFromHomeKm > maxDistanceKm) {
          return false;
        }
        return true;
      }).toList();

      switch (sort ?? ListingSort.distance) {
        case ListingSort.distance:
          result.sort(
            (a, b) => a.distanceFromHomeKm.compareTo(b.distanceFromHomeKm),
          );
        case ListingSort.rating:
          result.sort((a, b) => b.rating.compareTo(a.rating));
        case ListingSort.priceLow:
          result.sort((a, b) => a.priceFromQar.compareTo(b.priceFromQar));
      }

      const pageSize = 20;
      final offset = (page - 1) * pageSize;
      return result.skip(offset).take(pageSize).toList();
    } catch (e) {
      throw CatalogException('Failed to load listings: $e');
    }
  }

  @override
  Future<Listing> listing(String id) async {
    await Future<void>.delayed(_latency);
    final found = listingById(id);
    if (found == null) throw CatalogException('Listing not found: $id');
    return found;
  }

  @override
  Future<List<CategoryCount>> categories() async {
    await Future<void>.delayed(_latency);
    return CategoryType.values.map((cat) {
      final count = mockListings
          .where((l) => l.category == cat && l.status == ListingStatus.active)
          .length;
      return CategoryCount(key: cat, count: count);
    }).toList();
  }

  @override
  Future<List<String>> tags(String category) async {
    await Future<void>.delayed(_latency);
    final target = _categoryFromKey(category);
    final seen = <String>{};
    final ordered = <String>[];
    for (final l in mockListings) {
      if (l.status != ListingStatus.active) continue;
      if (target != null && l.category != target) continue;
      for (final tag in l.tags) {
        if (seen.add(tag)) ordered.add(tag);
      }
    }
    return ordered;
  }

  /// Maps a backend category key (e.g. `SCHOOLS`) back to a [CategoryType].
  /// An empty / unknown key means "all categories" (null).
  CategoryType? _categoryFromKey(String key) {
    if (key.isEmpty) return null;
    for (final cat in CategoryType.values) {
      if (cat.name.toUpperCase() == key.toUpperCase()) return cat;
    }
    return null;
  }
}
