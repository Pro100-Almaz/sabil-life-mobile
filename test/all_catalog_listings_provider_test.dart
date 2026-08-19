import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sabil_life/core/state/provider_providers.dart';
import 'package:sabil_life/data/mock/mock_listings.dart';
import 'package:sabil_life/data/models/listing.dart';
import 'package:sabil_life/data/repositories/catalog_repository.dart';

void main() {
  test(
    'map listings provider loads every page and removes duplicates',
    () async {
      final repository = _PagedCatalogRepository();
      final container = ProviderContainer(
        overrides: [catalogRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final listings = await container.read(
        allCatalogListingsProvider(const ListingsFilter()).future,
      );

      expect(repository.requestedPages, [1, 2]);
      expect(listings.map((listing) => listing.id), [
        mockListings[0].id,
        mockListings[1].id,
        mockListings[2].id,
      ]);
    },
  );
}

class _PagedCatalogRepository implements CatalogRepository {
  final List<int> requestedPages = [];

  @override
  Future<ListingPage> listings({
    CategoryType? category,
    String? query,
    Set<String> tags = const {},
    int? priceMax,
    String? ageGroup,
    double? lat,
    double? lng,
    double? maxDistanceKm,
    ListingSort? sort,
    int page = 1,
  }) async {
    requestedPages.add(page);
    if (page == 1) {
      return ListingPage(
        results: [mockListings[0], mockListings[1]],
        count: 3,
        page: page,
        hasNext: true,
        hasPrevious: false,
      );
    }
    return ListingPage(
      results: [mockListings[1], mockListings[2]],
      count: 3,
      page: page,
      hasNext: false,
      hasPrevious: true,
    );
  }

  @override
  Future<List<CategoryCount>> categories() => throw UnimplementedError();

  @override
  Future<Listing> listing(String id) => throw UnimplementedError();

  @override
  Future<List<String>> tags(String category) => throw UnimplementedError();

  @override
  Future<List<TagGroup>> tagGroups(String category) =>
      throw UnimplementedError();
}
