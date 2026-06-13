import '../mock/mock_inquiries.dart';
import '../mock/mock_listings.dart';
import '../models/inquiry.dart';

abstract class InquiryRepository {
  /// Inquiries the given family user has sent.
  Future<List<Inquiry>> myInquiries(String familyId);

  /// Create a new inquiry from a family against a listing. Returns the saved
  /// inquiry (with id + createdAt populated).
  Future<Inquiry> create({
    required String listingId,
    required String familyId,
    required String familyName,
    required String familyEmail,
    required String message,
    String? tutorIdHint,
  });
}

class MockInquiryRepository implements InquiryRepository {
  static const Duration _latency = Duration(milliseconds: 300);

  @override
  Future<List<Inquiry>> myInquiries(String familyId) async {
    await Future<void>.delayed(_latency);
    return seedInquiries.where((i) => i.familyId == familyId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<Inquiry> create({
    required String listingId,
    required String familyId,
    required String familyName,
    required String familyEmail,
    required String message,
    String? tutorIdHint,
  }) async {
    await Future<void>.delayed(_latency);
    final listing = listingById(listingId);
    if (listing == null) {
      throw StateError('Unknown listing: $listingId');
    }
    if (listing.ownerId == null) {
      throw StateError(
        'Listing $listingId has no owner; cannot create an inquiry',
      );
    }
    final inquiry = Inquiry(
      id: 'inq-${DateTime.now().millisecondsSinceEpoch}',
      listingId: listingId,
      familyId: familyId,
      familyName: familyName,
      familyEmail: familyEmail,
      providerId: listing.ownerId!,
      message: message.trim(),
      status: InquiryStatus.pending,
      createdAt: DateTime.now(),
      tutorIdHint: tutorIdHint,
    );
    seedInquiries.add(inquiry);
    return inquiry;
  }
}
