import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock/mock_listings.dart';
import '../../data/models/listing.dart';
import '../util/distance.dart';

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
  });

  final String query;
  final CategoryType? selectedCategory;
  final double maxDistanceKm;
  final int priceMax;
  final String? ageGroup;
  final SortMode sortMode;

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
    );
  }
}

class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(const FilterState());

  void setQuery(String query) => state = state.copyWith(query: query);

  void setCategory(CategoryType? category) =>
      state = state.copyWith(selectedCategory: () => category);

  void setSortMode(SortMode mode) => state = state.copyWith(sortMode: mode);

  void applyFilters({
    required double maxDistanceKm,
    required int priceMax,
    required String? ageGroup,
  }) {
    state = state.copyWith(
      maxDistanceKm: maxDistanceKm,
      priceMax: priceMax,
      ageGroup: () => ageGroup,
    );
  }

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

/// Synchronous, in-memory filtered + sorted view over [mockListings].
final filteredListingsProvider = Provider<List<Listing>>((ref) {
  final filter = ref.watch(filterProvider);
  final query = filter.query.trim().toLowerCase();

  final result = mockListings.where((listing) {
    if (filter.selectedCategory != null &&
        listing.category != filter.selectedCategory) {
      return false;
    }
    if (query.isNotEmpty) {
      final haystack =
          '${listing.title} ${listing.subtitle} '
                  '${listing.neighborhood}'
              .toLowerCase();
      if (!haystack.contains(query)) return false;
    }
    if (listing.distanceFromHomeKm > filter.maxDistanceKm) return false;
    if (listing.priceFromQar > filter.priceMax) return false;
    if (filter.ageGroup != null &&
        !listing.ageGroups.contains(filter.ageGroup)) {
      return false;
    }
    return true;
  }).toList();

  switch (filter.sortMode) {
    case SortMode.distance:
      result.sort(
        (a, b) => a.distanceFromHomeKm.compareTo(b.distanceFromHomeKm),
      );
    case SortMode.rating:
      result.sort((a, b) => b.rating.compareTo(a.rating));
    case SortMode.priceLow:
      result.sort((a, b) => a.priceFromQar.compareTo(b.priceFromQar));
  }
  return result;
});
