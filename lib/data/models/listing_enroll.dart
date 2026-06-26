import 'listing.dart';

/// Status of a family's request against a listing — the backend `ListingClient`
/// entity. Mirrors the backend's `PENDING` / `ACCEPTED` / `REJECTED` values.
enum ListingEnrollmentStatus {
  pending,
  accepted,
  rejected;

  String toBackend() => switch (this) {
    ListingEnrollmentStatus.pending => 'PENDING',
    ListingEnrollmentStatus.accepted => 'ACCEPTED',
    ListingEnrollmentStatus.rejected => 'REJECTED',
  };

  static ListingEnrollmentStatus fromBackend(String? raw) =>
      switch (raw?.toUpperCase()) {
        'ACCEPTED' => ListingEnrollmentStatus.accepted,
        'REJECTED' => ListingEnrollmentStatus.rejected,
        _ => ListingEnrollmentStatus.pending,
      };
}

/// Family-side view of a listing request — `GET/POST /listing-requests/`.
/// Embeds the full listing card so "My requests" can render without a second
/// fetch.
class ListingEnrollment {
  const ListingEnrollment({
    required this.id,
    required this.listing,
    required this.status,
    required this.createdAt,
    this.comment = '',
    this.updatedAt,
  });

  /// The request id — pass to `DELETE /listing-requests/{id}/` to cancel.
  final int id;
  final Listing listing;
  final ListingEnrollmentStatus status;

  /// Owner's note, if any — typically left when a request is rejected.
  /// Empty string when none.
  final String comment;
  final DateTime createdAt;
  final DateTime? updatedAt;
}

/// The requesting family as seen by the listing owner.
class ListingClientUser {
  const ListingClientUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
  });

  final int id;
  final String fullName;
  final String email;
  final String? phone;
}

/// Owner-side view of a listing request — `GET/PATCH /listing-clients/`.
/// Carries the requesting family's contact details and the owned listing.
class ListingClient {
  const ListingClient({
    required this.id,
    required this.user,
    required this.listingId,
    required this.listingTitle,
    required this.status,
    required this.createdAt,
    this.comment = '',
    this.updatedAt,
  });

  final int id;
  final ListingClientUser user;
  final String listingId;
  final String listingTitle;
  final ListingEnrollmentStatus status;

  /// Owner's note, if any — required when rejecting, optional otherwise.
  /// Empty string when none.
  final String comment;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ListingClient copyWith({ListingEnrollmentStatus? status, String? comment}) =>
      ListingClient(
        id: id,
        user: user,
        listingId: listingId,
        listingTitle: listingTitle,
        status: status ?? this.status,
        comment: comment ?? this.comment,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
