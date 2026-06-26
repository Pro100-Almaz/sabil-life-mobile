enum InquiryStatus {
  new_,
  contacted,
  accepted,
  declined,
  completed,
  cancelled,
  // Legacy mock alias — treated as new_ on backend.
  pending;

  String toBackend() => switch (this) {
    InquiryStatus.new_ => 'NEW',
    InquiryStatus.contacted => 'CONTACTED',
    InquiryStatus.accepted => 'ACCEPTED',
    InquiryStatus.declined => 'DECLINED',
    InquiryStatus.completed => 'COMPLETED',
    InquiryStatus.cancelled => 'CANCELLED',
    InquiryStatus.pending => 'NEW',
  };

  static InquiryStatus fromBackend(String? raw) => switch (raw?.toUpperCase()) {
    'NEW' => InquiryStatus.new_,
    'CONTACTED' => InquiryStatus.contacted,
    'ACCEPTED' => InquiryStatus.accepted,
    'DECLINED' => InquiryStatus.declined,
    'COMPLETED' => InquiryStatus.completed,
    'CANCELLED' => InquiryStatus.cancelled,
    _ => InquiryStatus.new_,
  };

  /// The family may cancel only while the inquiry is still live; the backend
  /// returns 409 for terminal states (declined / completed / cancelled).
  bool get isCancellable =>
      this == InquiryStatus.new_ ||
      this == InquiryStatus.contacted ||
      this == InquiryStatus.accepted ||
      this == InquiryStatus.pending;
}

/// Lightweight tutor summary embedded in a family-side inquiry response
/// (`tutor` block of the backend contract).
class InquiryTutor {
  const InquiryTutor({
    required this.id,
    required this.fullName,
    this.subjects = const [],
    this.isVerified = false,
  });

  factory InquiryTutor.fromJson(Map<String, dynamic> json) => InquiryTutor(
    id: json['id']?.toString() ?? '',
    fullName: (json['full_name'] ?? '') as String,
    subjects:
        (json['subjects'] as List?)?.map((e) => e.toString()).toList() ??
        const [],
    isVerified: (json['is_verified'] ?? false) as bool,
  );

  final String id;
  final String fullName;
  final List<String> subjects;
  final bool isVerified;
}

/// A family's request to engage with a tutor. Fields mirror the backend
/// tutor-based Inquiry contract.
class Inquiry {
  const Inquiry({
    required this.id,
    required this.message,
    required this.status,
    required this.createdAt,
    this.tutorId,
    this.tutor,
    this.familyId,
    this.familyName,
    this.familyEmail,
    this.familyPhone,
    this.contactRevealed = false,
    this.updatedAt,
  });

  final String id;
  final String message;
  final InquiryStatus status;
  final DateTime createdAt;

  /// The tutor this inquiry targets (tutor-based contract).
  final String? tutorId;
  final InquiryTutor? tutor;

  // Nullable — not present in family-side backend responses.
  final String? familyId;
  final String? familyName;

  /// Revealed to the provider only once they accept.
  final String? familyEmail;
  final String? familyPhone;

  final bool contactRevealed;
  final DateTime? updatedAt;

  Inquiry copyWith({InquiryStatus? status}) => Inquiry(
    id: id,
    message: message,
    status: status ?? this.status,
    createdAt: createdAt,
    tutorId: tutorId,
    tutor: tutor,
    familyId: familyId,
    familyName: familyName,
    familyEmail: familyEmail,
    familyPhone: familyPhone,
    contactRevealed: contactRevealed,
    updatedAt: updatedAt,
  );
}
