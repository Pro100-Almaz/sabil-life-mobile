import 'package:dio/dio.dart';

import '../models/listing.dart';
import '../models/listing_enroll.dart';
import '../repositories/listing_enroll_repository.dart';
import 'api_client.dart';
import 'listing_parser.dart';

class HttpListingEnrollmentRepository implements ListingEnrollmentRepository {
  HttpListingEnrollmentRepository();

  Dio get _dio => apiClient.dio;

  // ── Family side ────────────────────────────────────────────────────────────

  @override
  Future<List<ListingEnrollment>> myEnrollments() async {
    try {
      final response = await _dio.get('/listing-enrollment/');
      final data = response.data;
      final items = data is Map<String, dynamic>
          ? (data['results'] as List? ?? const [])
          : (data as List? ?? const []);
      return items
          .whereType<Map>()
          .map((item) => _parseEnrollment(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (e) {
      throw StateError(_extractError(e));
    }
  }

  @override
  Future<ListingEnrollment> enroll(String listingId) async {
    try {
      final response = await _dio.post(
        '/listing-enrollment/',
        data: {'listing': listingId},
      );
      return _parseEnrollment(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      throw StateError(_extractError(e));
    }
  }

  @override
  Future<void> cancelEnrollment(int requestId) async {
    try {
      await _dio.delete('/listing-enrollment/$requestId/', data: null);
    } on DioException catch (e) {
      throw StateError(_extractError(e));
    }
  }

  // ── Owner side ─────────────────────────────────────────────────────────────

  @override
  Future<List<ListingClient>> clients({String? listingId}) async {
    try {
      final response = await _dio.get(
        '/listing-clients/',
        queryParameters: listingId == null ? null : {'listing': listingId},
      );
      final data = response.data;
      final items = data is Map<String, dynamic>
          ? (data['results'] as List? ?? const [])
          : (data as List? ?? const []);
      return items
          .whereType<Map>()
          .map((item) => _parseClient(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (e) {
      throw StateError(_extractError(e));
    }
  }

  @override
  Future<ListingClient> updateClientStatus(
    int id,
    ListingEnrollmentStatus status, {
    String? comment,
  }) async {
    try {
      final payload = <String, dynamic>{'status': status.toBackend()};
      if (comment != null) payload['comment'] = comment;
      final response = await _dio.patch('/listing-clients/$id/', data: payload);
      return _parseClient(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      throw StateError(_extractError(e));
    }
  }

  // ── Parsing ────────────────────────────────────────────────────────────────

  ListingEnrollment _parseEnrollment(Map<String, dynamic> d) {
    final rawListing = d['listing'];
    final Listing listing;
    if (rawListing is Map) {
      // GET shape — full card embedded.
      listing = ListingParser.fromCard(Map<String, dynamic>.from(rawListing));
    } else {
      // POST shape — `listing` is a bare uuid plus a separate `listing_title`.
      listing = _minimalListing(
        rawListing?.toString() ?? '',
        d['listing_title']?.toString() ?? '',
      );
    }
    return ListingEnrollment(
      id: ListingParser.toInt(d['id']),
      listing: listing,
      status: ListingEnrollmentStatus.fromBackend(d['status']?.toString()),
      comment: d['comment']?.toString() ?? '',
      createdAt: _parseDate(d['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(d['updated_at']),
    );
  }

  ListingClient _parseClient(Map<String, dynamic> d) {
    final user = (d['user'] as Map?) != null
        ? Map<String, dynamic>.from(d['user'] as Map)
        : const <String, dynamic>{};
    return ListingClient(
      id: ListingParser.toInt(d['id']),
      user: ListingClientUser(
        id: ListingParser.toInt(user['id']),
        fullName: user['full_name']?.toString() ?? '',
        email: user['email']?.toString() ?? '',
        phone: user['phone']?.toString(),
      ),
      listingId: d['listing']?.toString() ?? '',
      listingTitle: d['listing_title']?.toString() ?? '',
      status: ListingEnrollmentStatus.fromBackend(d['status']?.toString()),
      comment: d['comment']?.toString() ?? '',
      createdAt: _parseDate(d['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(d['updated_at']),
    );
  }

  /// Builds a placeholder [Listing] from just an id + title — used for the POST
  /// response, which doesn't embed the full card. "My requests" refetches the
  /// full list immediately after, so this is only ever a transient value.
  Listing _minimalListing(String id, String title) => Listing(
    id: id,
    title: title,
    category: CategoryType.masterclasses,
    subtitle: '',
    neighborhood: '',
    lat: 0,
    lng: 0,
    rating: 0,
    reviewCount: 0,
    priceFromQar: 0,
    imageUrls: const [],
    ageGroups: const [],
    isFeatured: false,
    description: '',
    highlights: const [],
    isOnline: false,
  );

  DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    return DateTime.tryParse(raw.toString());
  }

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      if (data.containsKey('detail')) return data['detail'].toString();
      if (data.containsKey('message')) return data['message'].toString();
      if (data.isNotEmpty) {
        final first = data.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
        return first.toString();
      }
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}
