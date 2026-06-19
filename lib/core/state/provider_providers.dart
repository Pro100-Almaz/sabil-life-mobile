import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sabil_life/data/api/provider.dart';

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
