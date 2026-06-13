import '../mock/mock_inquiries.dart';
import '../mock/mock_listings.dart';
import '../models/commission.dart';
import '../models/inquiry.dart';
import '../models/listing.dart';

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

  Future<List<Inquiry>> incomingInquiries(String providerId);

  /// Accepting flips status, reveals the family's contact info and accrues a
  /// commission. Returns the new commission.
  Future<Commission> acceptInquiry(String inquiryId);

  Future<Inquiry> declineInquiry(String inquiryId);

  Future<EarningsSummary> earnings(String providerId);
}

class MockProviderRepository implements ProviderRepository {
  static const Duration _latency = Duration(milliseconds: 250);

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
  Future<List<Inquiry>> incomingInquiries(String providerId) async {
    await Future<void>.delayed(_latency);
    return seedInquiries.where((i) => i.providerId == providerId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<Commission> acceptInquiry(String inquiryId) async {
    await Future<void>.delayed(_latency);
    final index = seedInquiries.indexWhere((i) => i.id == inquiryId);
    if (index < 0) throw StateError('Unknown inquiry: $inquiryId');
    final accepted = seedInquiries[index].copyWith(
      status: InquiryStatus.accepted,
    );
    seedInquiries[index] = accepted;

    final commission = Commission(
      id: 'cms-${DateTime.now().millisecondsSinceEpoch}',
      inquiryId: accepted.id,
      providerId: accepted.providerId,
      amountQar: kInquiryCommissionQar,
      status: CommissionStatus.pending,
      createdAt: DateTime.now(),
    );
    seedCommissions.add(commission);
    return commission;
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
  Future<EarningsSummary> earnings(String providerId) async {
    await Future<void>.delayed(_latency);
    final commissions =
        seedCommissions.where((c) => c.providerId == providerId).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final accepted = seedInquiries
        .where(
          (i) =>
              i.providerId == providerId && i.status == InquiryStatus.accepted,
        )
        .length;
    final pending = commissions
        .where((c) => c.status == CommissionStatus.pending)
        .fold<int>(0, (sum, c) => sum + c.amountQar);
    final paid = commissions
        .where((c) => c.status == CommissionStatus.paid)
        .fold<int>(0, (sum, c) => sum + c.amountQar);
    return EarningsSummary(
      acceptedStudents: accepted,
      pendingQar: pending,
      paidQar: paid,
      commissions: commissions,
    );
  }
}
