import '../models/listing_enroll.dart';

/// Listing requests — the backend `ListingClient` entity, seen from two sides:
///
/// * Family side: `/listing-enroll/` (list / create / cancel own requests).
/// * Owner side:  `/listing-clients/` (list clients, update their status).
///
/// Both endpoints read the caller's identity from the bearer token, so no
/// family/owner id is passed — mirroring the planned backend contract.
abstract class ListingEnrollmentRepository {
  // ── Family side ────────────────────────────────────────────────────────────

  Future<List<ListingEnrollment>> myEnrollments();

  Future<ListingEnrollment> enroll(String listingId);

  Future<void> cancelEnrollment(int requestId);

  // ── Owner side ─────────────────────────────────────────────────────────────

  Future<List<ListingClient>> clients({String? listingId});

  Future<ListingClient> updateClientStatus(
    int id,
    ListingEnrollmentStatus status, {
    String? comment,
  });
}
