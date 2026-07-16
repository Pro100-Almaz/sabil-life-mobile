import '../models/listing.dart';

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

