import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../data/models/listing.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../data/mock/mock_home.dart';
import 'provider_providers.dart';

enum SortMode { distance, rating, priceLow }

const double kMaxDistanceCeilingKm = 30;
const int kPriceCeilingQar = 50000;

/// Age buckets used across mock data and the filter sheet.
const List<String> kAgeGroups = ['0-3', '3-5', '6-11', '12-15', '16+'];

class FilterState {
  const FilterState({
    this.query = '',
    this.selectedCategory,
    this.maxDistanceKm = kMaxDistanceCeilingKm,
    this.priceMax = kPriceCeilingQar,
    this.ageGroup,
    this.sortMode = SortMode.distance,
    this.tag,
    this.userPosition = mockHome,
  });

  final LatLng userPosition;
  final String query;
  final CategoryType? selectedCategory;
  final double maxDistanceKm;
  final int priceMax;
  final String? ageGroup;
  final SortMode sortMode;
  final String? tag;

  bool get hasActiveFilters =>
      maxDistanceKm < kMaxDistanceCeilingKm ||
      priceMax < kPriceCeilingQar ||
      ageGroup != null;

  FilterState copyWith({
    String? query,
    CategoryType? Function()? selectedCategory,
    double? maxDistanceKm,
    int? priceMax,
    String? Function()? ageGroup,
    SortMode? sortMode,
    String? Function()? tag,
    LatLng? userPosition
  }) {
    return FilterState(
      query: query ?? this.query,
      selectedCategory: selectedCategory != null
          ? selectedCategory()
          : this.selectedCategory,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      priceMax: priceMax ?? this.priceMax,
      ageGroup: ageGroup != null ? ageGroup() : this.ageGroup,
      sortMode: sortMode ?? this.sortMode,
      tag: tag != null ? tag() : this.tag,
      userPosition: userPosition ?? this.userPosition
    );
  }
}

class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(const FilterState());

  void setQuery(String query) => state = state.copyWith(query: query);

  /// Switching category clears any active tag — tags are category-scoped.
  void setCategory(CategoryType? category) =>
      state = state.copyWith(selectedCategory: () => category, tag: () => null);

  void setTag(String? tag) => state = state.copyWith(tag: () => tag);

  void setSortMode(SortMode mode) => state = state.copyWith(sortMode: mode);

  void applyFilters({
    required double maxDistanceKm,
    required int priceMax,
    required String? ageGroup,
    required LatLng userPosition
  }) {
    state = state.copyWith(
      maxDistanceKm: maxDistanceKm,
      priceMax: priceMax,
      ageGroup: () => ageGroup,
      userPosition: userPosition
    );
  }

  void updateOrigin(LatLng? userPosition) => state = state.copyWith(userPosition: userPosition);

  void resetFilters() {
    state = state.copyWith(
      maxDistanceKm: kMaxDistanceCeilingKm,
      priceMax: kPriceCeilingQar,
      ageGroup: () => null,
    );
  }
}

final filterProvider = StateNotifierProvider<FilterNotifier, FilterState>(
  (ref) => FilterNotifier(),
);

ListingSort _toListingSort(SortMode mode) => switch (mode) {
  SortMode.distance => ListingSort.distance,
  SortMode.rating => ListingSort.rating,
  SortMode.priceLow => ListingSort.priceLow,
};

/// Async filtered + sorted view over the catalog (HTTP or mock depending on
/// [catalogRepositoryProvider]).  Screens watch this and handle the three
/// [AsyncValue] states: loading / error / data.
/// The [ListingsFilter] derived from the current [filterProvider] state. Exposed
/// so screens can await a real refresh of `catalogListingsProvider(thisFilter)`.
final listingsFilterProvider = Provider<ListingsFilter>((ref) {
  final filter = ref.watch(filterProvider);
  final latitude = filter.userPosition.latitude;
  final longitude = filter.userPosition.longitude;
  return ListingsFilter(
    category: filter.selectedCategory,
    query: filter.query.isEmpty ? null : filter.query,
    tag: filter.tag,
    priceMax: filter.priceMax < kPriceCeilingQar ? filter.priceMax : null,
    ageGroup: filter.ageGroup,
    maxDistanceKm: filter.maxDistanceKm < kMaxDistanceCeilingKm
        ? filter.maxDistanceKm
        : null,
    sort: _toListingSort(filter.sortMode),
    page: 1,
    lat: latitude,
    lng: longitude,
  );
});

final filteredListingsProvider = Provider<AsyncValue<List<Listing>>>((ref) {
  return ref.watch(catalogListingsProvider(ref.watch(listingsFilterProvider)));
});
