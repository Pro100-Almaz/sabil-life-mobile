import '../models/inquiry.dart';

abstract class InquiryRepository {
  /// Inquiries the signed-in family user has sent.
  /// [familyId] is accepted for interface compat but ignored by the HTTP impl
  /// (backend reads family from the token).
  Future<List<Inquiry>> myInquiries(String familyId);

  /// Create a new inquiry from the signed-in family to a tutor. Only
  /// [tutorId] + [message] go on the wire; family identity comes from the token.
  Future<Inquiry> create({required String tutorId, required String message});

  /// Cancel one of the family's own inquiries (→ CANCELLED). Returns the
  /// updated inquiry.
  Future<Inquiry> cancel(String inquiryId);
}
