import '../models/commission.dart';
import '../models/inquiry.dart';
import '../models/listing.dart';
import '../models/provider_profile.dart';
import '../models/provider_verification.dart';
import '../models/auth_user.dart';
import '../models/subscription.dart';

class EarningsSummary {
  const EarningsSummary({
    required this.acceptedStudents,
    required this.pendingQar,
    required this.paidQar,
    required this.commissions,
  });

  final int acceptedStudents;
  final int pendingQar;
  final int paidQar;
  final List<Commission> commissions;
}

abstract class ProviderRepository {
  Future<List<Listing>> myListings(String providerId);

  Future<Listing> upsertListing(Listing listing, {required ListingStatus status});

  /// Upload one or more image files to a listing. Returns the created images.
  Future<List<ListingImage>> uploadListingImages(
    String listingId,
    List<String> paths,
  );

  /// Delete a single image from a listing by its server id.
  Future<void> deleteListingImage(String listingId, String imageId);

  Future<ProviderProfile> myProfile();

  /// Returns the existing tutor detail, or `null` if none created yet.
  Future<ProviderProfile?> tutorDetail(String userId);

  /// Returns the masterclass provider detail, or `null` if not requested yet.
  Future<ProviderProfile?> masterclassDetail(String userId);

  /// The caller's own verification records, one per provider type.
  Future<List<ProviderVerification>> myVerifications();

  /// Submit a verification request for [providerType] (`TUTOR`/`MASTERCLASS`).
  Future<ProviderVerification> requestVerification(UserRole providerType);

  /// Cancel a pending/rejected verification request for [providerType].
  Future<ProviderVerification> cancelVerification(UserRole providerType);

  Future<ProviderProfile> createTutorDetail({
    String? displayName,
    String? bio,
    List<String>? subjects,
    int? hourlyRateQar,
    String? availability,
    List<String>? formats,
    List<String>? ageGroups,
    List<String>? languages,
    int? yearsExperience,
    String? credentials,
    String? avatarUrl,
    bool? trialAvailable,
  });

  Future<ProviderProfile> updateTutorDetail({
    String? displayName,
    String? bio,
    List<String>? subjects,
    int? hourlyRateQar,
    String? availability,
    List<String>? formats,
    List<String>? ageGroups,
    List<String>? languages,
    int? yearsExperience,
    String? credentials,
    String? avatarUrl,
    bool? trialAvailable,
  });

  Future<String> uploadAvatar(String filePath);

  Future<List<Inquiry>> incomingInquiries(String providerId);

  Future<void> markContacted(String inquiryId);

  /// Accepting flips status and reveals family contact info.
  /// Returns the updated Inquiry (no commission — billing is Phase 6).
  Future<void> acceptInquiry(String inquiryId);

  Future<void> declineInquiry(String inquiryId);

  Future<void> completeInquiry(String inquiryId);

  Future<List<Subscription>> incomingSubscriptions({
    String? listingId,
    SubscriptionStatus? status,
  });

  Future<EarningsSummary> earnings(String providerId);
}
