enum InquiryStatus { pending, accepted, declined }

/// A family's request to engage with a tutoring centre or masterclass
/// provider. Fields mirror the planned backend contract.
class Inquiry {
  const Inquiry({
    required this.id,
    required this.listingId,
    required this.familyId,
    required this.familyName,
    required this.familyEmail,
    required this.providerId,
    required this.message,
    required this.status,
    required this.createdAt,
    this.tutorIdHint,
  });

  final String id;
  final String listingId;
  final String familyId;
  final String familyName;

  /// Revealed to the provider only once they accept the inquiry.
  final String familyEmail;
  final String providerId;
  final String message;
  final InquiryStatus status;
  final DateTime createdAt;

  /// Optional pointer to an individual tutor the family had in mind when they
  /// requested the centre listing.
  final String? tutorIdHint;

  Inquiry copyWith({InquiryStatus? status}) => Inquiry(
    id: id,
    listingId: listingId,
    familyId: familyId,
    familyName: familyName,
    familyEmail: familyEmail,
    providerId: providerId,
    message: message,
    status: status ?? this.status,
    createdAt: createdAt,
    tutorIdHint: tutorIdHint,
  );
}
