import 'auth_user.dart';

/// Lifecycle of a [ProviderVerification] request, mirroring the backend
/// `StatusChoices` text choices. [none] is a client-only sentinel meaning no
/// verification record exists yet for a given provider type.
enum VerificationStatus {
  pending,
  approved,
  rejected,
  updated,
  cancelled,
  none,
}

extension VerificationStatusX on VerificationStatus {
  static VerificationStatus fromBackend(String? raw) =>
      switch (raw?.toUpperCase()) {
        'PENDING' => VerificationStatus.pending,
        'APPROVED' => VerificationStatus.approved,
        'REJECTED' => VerificationStatus.rejected,
        'UPDATED' => VerificationStatus.updated,
        'CANCELLED' => VerificationStatus.cancelled,
        _ => VerificationStatus.none,
      };

  /// The request is approved — the provider can use their interface.
  bool get isApproved => this == VerificationStatus.approved;

  /// The request was turned down — show the admin comment.
  bool get isRejected => this == VerificationStatus.rejected;

  /// Awaiting an admin decision (a fresh request or an edited resubmission).
  bool get isUnderReview =>
      this == VerificationStatus.pending || this == VerificationStatus.updated;

  /// No active request — the provider can (re)submit one.
  bool get canRequest =>
      this == VerificationStatus.none || this == VerificationStatus.cancelled;
}

/// A provider's verification record for a single [providerType]. The HTTP swap
/// (`GET /provider/verify/`) returns a list of these.
class ProviderVerification {
  const ProviderVerification({
    this.id,
    this.userId,
    this.email = '',
    this.fullName = '',
    required this.providerType,
    required this.status,
    this.comment = '',
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final int? userId;
  final String email;
  final String fullName;
  final UserRole providerType;
  final VerificationStatus status;

  /// When [status] is rejected this holds the admin's reason; otherwise empty.
  final String comment;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isApproved => status.isApproved;
  bool get isRejected => status.isRejected;
  bool get isUnderReview => status.isUnderReview;
  bool get canRequest => status.canRequest;

  /// A placeholder record for a provider type with no verification yet.
  factory ProviderVerification.none(UserRole providerType) =>
      ProviderVerification(
        providerType: providerType,
        status: VerificationStatus.none,
      );
}

/// Backend path segment for the `provider_type` (case-insensitive server-side).
extension ProviderTypePath on UserRole {
  String get verifyPathSegment => switch (this) {
    UserRole.masterclass => 'MASTERCLASS',
    _ => 'TUTOR',
  };
}
