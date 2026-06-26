import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sabil_life/data/api/catalog.dart';
import 'package:sabil_life/data/api/inquiry.dart';
import 'package:sabil_life/data/api/listing_enroll.dart';
import 'package:sabil_life/data/api/provider.dart';
import 'package:sabil_life/data/api/review.dart';
import 'package:sabil_life/data/api/subscription.dart';
import 'package:sabil_life/data/api/suggestion.dart';
import 'package:sabil_life/data/api/tutor.dart';
import 'package:sabil_life/data/repositories/catalog_repository.dart';

import '../../data/models/auth_user.dart';
import '../../data/models/inquiry.dart';
import '../../data/models/listing.dart';
import '../../data/models/listing_enroll.dart';
import '../../data/models/provider_profile.dart';
import '../../data/models/provider_verification.dart';
import '../../data/models/review.dart';
import '../../data/models/subscription.dart';
import '../../data/models/suggestion.dart';
import '../../data/models/tutor.dart';
import '../../data/repositories/inquiry_repository.dart';
import '../../data/repositories/listing_enroll_repository.dart';
import '../../data/repositories/provider_repository.dart';
import '../../data/repositories/review_repository.dart';
import '../../data/repositories/subscription_repository.dart';
import '../../data/repositories/suggestion_repository.dart';
import '../../data/repositories/tutor_repository.dart';

final inquiryRepositoryProvider = Provider<InquiryRepository>(
  (ref) => HttpInquiryRepository(),
);

final providerRepositoryProvider = Provider<ProviderRepository>(
  (ref) => HttpProviderRepository(),
);

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => HttpCatalogRepository(),
);

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>(
  (ref) => HttpSubscriptionRepository(),
);

final reviewRepositoryProvider = Provider<ReviewRepository>(
  (ref) => HttpReviewRepository(),
);

// ── Inquiry providers ────────────────────────────────────────────────────────

final myInquiriesProvider = FutureProvider.family
    .autoDispose<List<Inquiry>, String>(
      (ref, familyId) =>
          ref.watch(inquiryRepositoryProvider).myInquiries(familyId),
    );

// ── Listing request providers ────────────────────────────────────────────────

final listingEnrollmentRepositoryProvider =
    Provider<ListingEnrollmentRepository>(
      (ref) => HttpListingEnrollmentRepository(),
    );

/// The signed-in family's own listing enrollments (newest-first).
///
/// Deliberately **not** `autoDispose`: it's cached for the session so re-opening
/// a listing shows the enrolled state instantly instead of re-fetching and
/// briefly flashing the "Enroll" button. It's prefetched in the family shell and
/// invalidated on logout ([AuthNotifier.logout]) so it never leaks across users.
final myListingEnrollmentsProvider = FutureProvider<List<ListingEnrollment>>(
  (ref) => ref.watch(listingEnrollmentRepositoryProvider).myEnrollments(),
);

/// Clients who requested a given listing (or all of the owner's listings when
/// [listingId] is null).
final listingClientsProvider = FutureProvider.family
    .autoDispose<List<ListingClient>, String?>(
      (ref, listingId) => ref
          .watch(listingEnrollmentRepositoryProvider)
          .clients(listingId: listingId),
    );

// ── Provider providers ───────────────────────────────────────────────────────

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

final providerProfileProvider = FutureProvider.autoDispose<ProviderProfile>(
  (ref) => ref.watch(providerRepositoryProvider).myProfile(),
);

final tutorDetailForUserProvider = FutureProvider.family
    .autoDispose<ProviderProfile?, String>(
      (ref, userId) =>
          ref.watch(providerRepositoryProvider).tutorDetail(userId),
    );

final masterclassDetailForUserProvider = FutureProvider.family
    .autoDispose<ProviderProfile?, String>(
      (ref, userId) =>
          ref.watch(providerRepositoryProvider).masterclassDetail(userId),
    );

/// The caller's own verification records, one per provider type.
final myVerificationsProvider =
    FutureProvider.autoDispose<List<ProviderVerification>>(
      (ref) => ref.watch(providerRepositoryProvider).myVerifications(),
    );

/// The verification record for a single [UserRole], or a [VerificationStatus.none]
/// placeholder when none exists yet.
final verificationForTypeProvider = FutureProvider.family
    .autoDispose<ProviderVerification, UserRole>((ref, type) async {
      final all = await ref.watch(myVerificationsProvider.future);
      for (final v in all) {
        if (v.providerType == type) return v;
      }
      return ProviderVerification.none(type);
    });

/// Filter key for [incomingSubscriptionsProvider].
class SubscriptionsFilter {
  const SubscriptionsFilter({this.listingId, this.status});

  final String? listingId;
  final SubscriptionStatus? status;

  @override
  bool operator ==(Object other) =>
      other is SubscriptionsFilter &&
      other.listingId == listingId &&
      other.status == status;

  @override
  int get hashCode => Object.hash(listingId, status);
}

final incomingSubscriptionsProvider = FutureProvider.family
    .autoDispose<List<Subscription>, SubscriptionsFilter>(
      (ref, filter) => ref
          .watch(providerRepositoryProvider)
          .incomingSubscriptions(
            listingId: filter.listingId,
            status: filter.status,
          ),
    );

// ── Catalog providers ────────────────────────────────────────────────────────

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

// ── Subscription providers ───────────────────────────────────────────────────

final mySubscriptionsProvider = FutureProvider.autoDispose<List<Subscription>>(
  (ref) => ref.watch(subscriptionRepositoryProvider).mine(),
);

final subscriptionDetailProvider = FutureProvider.family
    .autoDispose<Subscription, String>(
      (ref, id) => ref.watch(subscriptionRepositoryProvider).detail(id),
    );

// ── Review providers ─────────────────────────────────────────────────────────

final listingReviewsProvider = FutureProvider.family
    .autoDispose<List<Review>, String>(
      (ref, listingId) =>
          ref.watch(reviewRepositoryProvider).forListing(listingId),
    );

// ── Suggestion providers ─────────────────────────────────────────────────────

final suggestionRepositoryProvider = Provider<SuggestionRepository>(
  (ref) => HttpSuggestionRepository(),
);

final mySuggestionsProvider = FutureProvider.autoDispose<List<Suggestion>>(
  (ref) => ref.watch(suggestionRepositoryProvider).mySuggestions(),
);

// ── Tutor providers ─────────────────────────────────────────────────────────

final tutorRepositoryProvider = Provider<TutorRepository>(
  (ref) => HttpTutorRepository(),
);

final allTutorsProvider = FutureProvider.autoDispose<List<Tutor>>(
  (ref) => ref.watch(tutorRepositoryProvider).tutors(),
);

final availableSubjectsProvider = FutureProvider.autoDispose<List<String>>(
  (ref) => ref.watch(tutorRepositoryProvider).subjects(),
);
