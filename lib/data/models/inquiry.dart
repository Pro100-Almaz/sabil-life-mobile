enum InquiryStatus {
  new_,
  contacted,
  accepted,
  declined,
  completed,
  // Legacy mock alias — treated as new_ on backend.
  pending;

  String toBackend() => switch (this) {
    InquiryStatus.new_ => 'NEW',
    InquiryStatus.contacted => 'CONTACTED',
    InquiryStatus.accepted => 'ACCEPTED',
    InquiryStatus.declined => 'DECLINED',
    InquiryStatus.completed => 'COMPLETED',
    InquiryStatus.pending => 'NEW',
  };

  static InquiryStatus fromBackend(String? raw) => switch (raw?.toUpperCase()) {
    'NEW' => InquiryStatus.new_,
    'CONTACTED' => InquiryStatus.contacted,
    'ACCEPTED' => InquiryStatus.accepted,
    'DECLINED' => InquiryStatus.declined,
    'COMPLETED' => InquiryStatus.completed,
    _ => InquiryStatus.new_,
  };
}

/// A family's request to engage with a tutoring centre or masterclass
/// provider. Fields mirror the backend FamilyInquiry contract.
class Inquiry {
  const Inquiry({
    required this.id,
    required this.listingId,
    required this.providerId,
    required this.message,
    required this.status,
    required this.createdAt,
    this.familyId,
    this.familyName,
    this.familyEmail,
    this.familyPhone,
    this.contactRevealed = false,
    this.updatedAt,
    this.tutorIdHint,
  });

  final String id;
  final String listingId;
  final String providerId;
  final String message;
  final InquiryStatus status;
  final DateTime createdAt;

  // Nullable — not present in family-side backend responses.
  final String? familyId;
  final String? familyName;

  /// Revealed to the provider only once they accept.
  final String? familyEmail;
  final String? familyPhone;

  final bool contactRevealed;
  final DateTime? updatedAt;

  /// Optional pointer to an individual tutor the family had in mind.
  /// Mock-only metadata — ignored on the wire.
  final String? tutorIdHint;

  Inquiry copyWith({InquiryStatus? status}) => Inquiry(
    id: id,
    listingId: listingId,
    providerId: providerId,
    message: message,
    status: status ?? this.status,
    createdAt: createdAt,
    familyId: familyId,
    familyName: familyName,
    familyEmail: familyEmail,
    familyPhone: familyPhone,
    contactRevealed: contactRevealed,
    updatedAt: updatedAt,
    tutorIdHint: tutorIdHint,
  );
}
