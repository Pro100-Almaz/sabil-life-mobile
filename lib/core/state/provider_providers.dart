import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sabil_life/data/api/catalog.dart';
import 'package:sabil_life/data/api/provider.dart';
import 'package:sabil_life/data/repositories/catalog_repository.dart';

import '../../data/models/inquiry.dart';
import '../../data/models/listing.dart';
import '../../data/repositories/inquiry_repository.dart';
import '../../data/repositories/provider_repository.dart';

final inquiryRepositoryProvider = Provider<InquiryRepository>(
  (ref) => MockInquiryRepository(),
);

final providerRepositoryProvider = Provider<ProviderRepository>(
  (ref) => HttpProviderRepository(),
);

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => HttpCatalogRepository(),
);

final myInquiriesProvider = FutureProvider.family
    .autoDispose<List<Inquiry>, String>(
      (ref, familyId) =>
          ref.watch(inquiryRepositoryProvider).myInquiries(familyId),
    );

final myListingsProvider = FutureProvider.family
    .autoDispose<List<Listing>, String>(
      (ref, providerId) =>
          ref.watch(providerRepositoryProvider).myListings(providerId),
    );

final incomingInquiriesProvider = FutureProvider.family
    .autoDispose<List<Inquiry>, String>(
      (ref, providerId) =>
          ref.watch(providerRepositoryProvider).incomingInquiries(providerId),
    );

final earningsProvider = FutureProvider.family
    .autoDispose<EarningsSummary, String>(
      (ref, providerId) =>
          ref.watch(providerRepositoryProvider).earnings(providerId),
    );

final catalogListingsProvider = FutureProvider.family
    .autoDispose<List<Listing>, ListingsFilter>(
      (ref, filter) => ref
          .watch(catalogRepositoryProvider)
          .listings(
            category: filter.category,
            query: filter.query,
            priceMax: filter.priceMax,
            ageGroup: filter.ageGroup,
            lat: filter.lat,
            lng: filter.lng,
            maxDistanceKm: filter.maxDistanceKm,
            sort: filter.sort,
            page: filter.page,
          ),
    );

final catalogDetailProvider = FutureProvider.family
    .autoDispose<Listing, String>(
      (ref, id) => ref.watch(catalogRepositoryProvider).listing(id),
    );

final catalogCategoriesProvider =
    FutureProvider.autoDispose<List<CategoryCount>>(
      (ref) => ref.watch(catalogRepositoryProvider).categories(),
    );
