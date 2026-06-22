import '../mock/mock_inquiries.dart';
import '../mock/mock_listings.dart';
import '../models/commission.dart';
import '../models/inquiry.dart';
import '../models/listing.dart';
import '../models/provider_profile.dart';
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

  Future<Listing> upsertListing(Listing listing);

  Future<Listing> submitForReview(String listingId);

  Future<ProviderProfile> myProfile();

  /// Returns the existing tutor detail, or `null` if none created yet.
  Future<ProviderProfile?> tutorDetail();

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

  Future<Inquiry> markContacted(String inquiryId);

  /// Accepting flips status and reveals family contact info.
  /// Returns the updated Inquiry (no commission — billing is Phase 6).
  Future<Inquiry> acceptInquiry(String inquiryId);

  Future<Inquiry> declineInquiry(String inquiryId);

  Future<Inquiry> completeInquiry(String inquiryId);

  Future<List<Subscription>> incomingSubscriptions({
    String? listingId,
    SubscriptionStatus? status,
  });

  Future<EarningsSummary> earnings(String providerId);
}

class MockProviderRepository implements ProviderRepository {
  static const Duration _latency = Duration(milliseconds: 250);

  ProviderProfile _profile = const ProviderProfile(
    userId: 2,
    email: 'tutor@demo',
    fullName: 'Demo Tutor',
    role: UserRole.tutor,
    isVerified: true,
    displayName: 'Demo Tutor',
    bio: 'Experienced tutor covering Maths and Arabic.',
    subjects: ['Maths', 'Arabic'],
    hourlyRateQar: 120,
    availability: 'Mon-Fri 4pm-8pm',
  );

  @override
  Future<List<Listing>> myListings(String providerId) async {
    await Future<void>.delayed(_latency);
    return mockListings.where((l) => l.ownerId == providerId).toList();
  }

  @override
  Future<Listing> upsertListing(Listing listing) async {
    await Future<void>.delayed(_latency);
    final index = mockListings.indexWhere((l) => l.id == listing.id);
    if (index >= 0) {
      mockListings[index] = listing;
    } else {
      mockListings.add(listing);
    }
    return listing;
  }

  @override
  Future<Listing> submitForReview(String listingId) async {
    await Future<void>.delayed(_latency);
    final index = mockListings.indexWhere((l) => l.id == listingId);
    if (index < 0) throw StateError('Unknown listing: $listingId');
    final updated = mockListings[index].copyWith(status: ListingStatus.pending);
    mockListings[index] = updated;
    return updated;
  }

  @override
  Future<ProviderProfile> myProfile() async {
    await Future<void>.delayed(_latency);
    return _profile;
  }

  bool _tutorDetailCreated = true;

  @override
  Future<ProviderProfile?> tutorDetail() async {
    await Future<void>.delayed(_latency);
    return _tutorDetailCreated ? _profile : null;
  }

  ProviderProfile _applyTutorFields({
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
  }) {
    _profile = _profile.copyWith(
      displayName: displayName,
      bio: bio,
      subjects: subjects,
      hourlyRateQar: hourlyRateQar != null ? () => hourlyRateQar : null,
      availability: availability,
      formats: formats,
      ageGroups: ageGroups,
      languages: languages,
      yearsExperience: yearsExperience,
      credentials: credentials,
      avatarUrl: avatarUrl,
      trialAvailable: trialAvailable,
    );
    return _profile;
  }

  @override
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
  }) async {
    await Future<void>.delayed(_latency);
    _tutorDetailCreated = true;
    return _applyTutorFields(
      displayName: displayName,
      bio: bio,
      subjects: subjects,
      hourlyRateQar: hourlyRateQar,
      availability: availability,
      formats: formats,
      ageGroups: ageGroups,
      languages: languages,
      yearsExperience: yearsExperience,
      credentials: credentials,
      avatarUrl: avatarUrl,
      trialAvailable: trialAvailable,
    );
  }

  @override
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
  }) async {
    await Future<void>.delayed(_latency);
    return _applyTutorFields(
      displayName: displayName,
      bio: bio,
      subjects: subjects,
      hourlyRateQar: hourlyRateQar,
      availability: availability,
      formats: formats,
      ageGroups: ageGroups,
      languages: languages,
      yearsExperience: yearsExperience,
      credentials: credentials,
      avatarUrl: avatarUrl,
      trialAvailable: trialAvailable,
    );
  }

  @override
  Future<String> uploadAvatar(String filePath) async {
    await Future<void>.delayed(_latency);
    return 'https://example.com/avatars/mock-avatar.jpg';
  }

  @override
  Future<List<Inquiry>> incomingInquiries(String providerId) async {
    await Future<void>.delayed(_latency);
    return seedInquiries.where((i) => i.providerId == providerId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<Inquiry> markContacted(String inquiryId) async {
    await Future<void>.delayed(_latency);
    final index = seedInquiries.indexWhere((i) => i.id == inquiryId);
    if (index < 0) throw StateError('Unknown inquiry: $inquiryId');
    final updated = seedInquiries[index].copyWith(
      status: InquiryStatus.contacted,
    );
    seedInquiries[index] = updated;
    return updated;
  }

  @override
  Future<Inquiry> acceptInquiry(String inquiryId) async {
    await Future<void>.delayed(_latency);
    final index = seedInquiries.indexWhere((i) => i.id == inquiryId);
    if (index < 0) throw StateError('Unknown inquiry: $inquiryId');
    final accepted = seedInquiries[index].copyWith(
      status: InquiryStatus.accepted,
    );
    seedInquiries[index] = accepted;
    return accepted;
  }

  @override
  Future<Inquiry> declineInquiry(String inquiryId) async {
    await Future<void>.delayed(_latency);
    final index = seedInquiries.indexWhere((i) => i.id == inquiryId);
    if (index < 0) throw StateError('Unknown inquiry: $inquiryId');
    final declined = seedInquiries[index].copyWith(
      status: InquiryStatus.declined,
    );
    seedInquiries[index] = declined;
    return declined;
  }

  @override
  Future<Inquiry> completeInquiry(String inquiryId) async {
    await Future<void>.delayed(_latency);
    final index = seedInquiries.indexWhere((i) => i.id == inquiryId);
    if (index < 0) throw StateError('Unknown inquiry: $inquiryId');
    final completed = seedInquiries[index].copyWith(
      status: InquiryStatus.completed,
    );
    seedInquiries[index] = completed;
    return completed;
  }

  @override
  Future<List<Subscription>> incomingSubscriptions({
    String? listingId,
    SubscriptionStatus? status,
  }) async {
    await Future<void>.delayed(_latency);
    // Mock returns empty — no seed subscriptions for provider side.
    return const [];
  }

  @override
  Future<EarningsSummary> earnings(String providerId) async {
    await Future<void>.delayed(_latency);
    // Billing is Phase 6 — return empty summary.
    return const EarningsSummary(
      acceptedStudents: 0,
      pendingQar: 0,
      paidQar: 0,
      commissions: [],
    );
  }
}
