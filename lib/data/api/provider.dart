import 'dart:convert';

import 'package:dio/dio.dart';

import '../models/auth_user.dart';
import '../models/inquiry.dart';
import '../models/listing.dart';
import '../models/provider_profile.dart';
import '../models/provider_verification.dart';
import '../models/subscription.dart';
import '../repositories/provider_repository.dart';
import 'api_client.dart';
import 'listing_parser.dart';

class HttpProviderRepository implements ProviderRepository {
  HttpProviderRepository();

  Dio get _dio => apiClient.dio;

  // ── Profile ────────────────────────────────────────────────────────────────

  @override
  Future<ProviderProfile> myProfile() async {
    try {
      final response = await _dio.get('/provider/profile/');
      return _parseProfile(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      throw StateError(_extractError(e));
    }
  }

  @override
  Future<ProviderProfile?> tutorDetail(String userId) async {
    try {
      final response = await _dio.get('/provider/tutor-detail/');
      return _parseProfile(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw StateError(_extractError(e));
    }
  }

  @override
  Future<ProviderProfile?> masterclassDetail(String userId) async {
    try {
      final response = await _dio.get('/provider/masterclass-detail/');
      return _parseProfile(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw StateError(_extractError(e));
    }
  }

  // ── Verification ─────────────────────────────────────────────────────────

  @override
  Future<List<ProviderVerification>> myVerifications() async {
    try {
      final response = await _dio.get('/provider/verify/');
      final data = response.data;
      // Pagination is disabled on this view — the body is a bare array.
      final items = data is Map<String, dynamic> ? data['results'] : data;
      if (items is! List) return const [];
      return items
          .whereType<Map>()
          .map((item) => _parseVerification(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (e) {
      throw StateError(_extractError(e));
    }
  }

  @override
  Future<ProviderVerification> requestVerification(
    UserRole providerType,
  ) async {
    try {
      final response = await _dio.post(
        '/provider/verify/',
        data: {'provider_type': providerType.verifyPathSegment},
      );
      return _parseVerification(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw StateError(_extractError(e));
    }
  }

  @override
  Future<ProviderVerification> cancelVerification(UserRole providerType) async {
    try {
      await _dio.delete(
        '/provider/verify/${providerType.verifyPathSegment}/',
        data: null,
      );
      return ProviderVerification(
        providerType: providerType,
        status: VerificationStatus.cancelled,
      );
    } on DioException catch (e) {
      throw StateError(_extractError(e));
    }
  }

  ProviderVerification _parseVerification(Map<String, dynamic> d) {
    return ProviderVerification(
      id: (d['id'] as num?)?.toInt(),
      userId: (d['user_id'] as num?)?.toInt(),
      email: d['email'] as String? ?? '',
      fullName: d['full_name'] as String? ?? '',
      providerType: _parseRole(d['provider_type'] as String?),
      status: VerificationStatusX.fromBackend(d['status'] as String?),
      comment: d['comment'] as String? ?? '',
      createdAt: _parseDate(d['created_at']),
      updatedAt: _parseDate(d['updated_at']),
    );
  }

  Map<String, dynamic> _buildTutorPayload({
    String? displayName,
    String? bio,
    List<String>? subjects,
    int? hourlyRateQar,
    String? availability,
    List<String>? formats,
    List<String>? ageGroups,
    List<String>? languages,
    int? yearsExperience,
    String? credentials,
    String? avatarUrl,
    bool? trialAvailable,
  }) {
    final payload = <String, dynamic>{};
    if (displayName != null) payload['display_name'] = displayName;
    if (bio != null) payload['bio'] = bio;
    if (subjects != null) payload['subjects'] = subjects;
    if (hourlyRateQar != null) payload['price_per_hour_qar'] = hourlyRateQar;
    if (availability != null) payload['availability'] = availability;
    if (formats != null) payload['formats'] = formats;
    if (ageGroups != null) payload['age_groups'] = ageGroups;
    if (languages != null) payload['languages'] = languages;
    if (yearsExperience != null) payload['years_experience'] = yearsExperience;
    if (credentials != null) payload['credentials'] = credentials;
    if (avatarUrl != null) payload['avatar_url'] = avatarUrl;
    if (trialAvailable != null) payload['trial_available'] = trialAvailable;
    return payload;
  }

  @override
  Future<ProviderProfile> createTutorDetail({
    String? displayName,
    String? bio,
    List<String>? subjects,
    int? hourlyRateQar,
    String? availability,
    List<String>? formats,
    List<String>? ageGroups,
    List<String>? languages,
    int? yearsExperience,
    String? credentials,
    String? avatarUrl,
    bool? trialAvailable,
  }) async {
    final payload = _buildTutorPayload(
      displayName: displayName,
      bio: bio,
      subjects: subjects,
      hourlyRateQar: hourlyRateQar,
      availability: availability,
      formats: formats,
      ageGroups: ageGroups,
      languages: languages,
      yearsExperience: yearsExperience,
      credentials: credentials,
      avatarUrl: avatarUrl,
      trialAvailable: trialAvailable,
    );
    try {
      final response = await _dio.post(
        '/provider/tutor-detail/',
        data: payload,
      );
      return _parseProfile(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      throw StateError(_extractError(e));
    }
  }

  @override
  Future<ProviderProfile> updateTutorDetail({
    String? displayName,
    String? bio,
    List<String>? subjects,
    int? hourlyRateQar,
    String? availability,
    List<String>? formats,
    List<String>? ageGroups,
    List<String>? languages,
    int? yearsExperience,
    String? credentials,
    String? avatarUrl,
    bool? trialAvailable,
  }) async {
    final payload = _buildTutorPayload(
      displayName: displayName,
      bio: bio,
      subjects: subjects,
      hourlyRateQar: hourlyRateQar,
      availability: availability,
      formats: formats,
      ageGroups: ageGroups,
      languages: languages,
      yearsExperience: yearsExperience,
      credentials: credentials,
      avatarUrl: avatarUrl,
      trialAvailable: trialAvailable,
    );
    try {
      final response = await _dio.patch(
        '/provider/tutor-detail/',
        data: payload,
      );
      return _parseProfile(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      throw StateError(_extractError(e));
    }
  }

  ProviderProfile _parseProfile(Map<String, dynamic> d) {
    return ProviderProfile(
      userId: (d['user_id'] as num).toInt(),
      email: d['email'] as String? ?? '',
      fullName: d['full_name'] as String? ?? '',
      role: _parseRole(d['role'] as String?),
      isVerified: d['is_verified'] as bool? ?? false,
      displayName: d['display_name'] as String? ?? '',
      bio: d['bio'] as String? ?? '',
      subjects: List<String>.from((d['subjects'] as List?) ?? []),
      hourlyRateQar: d['price_per_hour_qar'] != null
          ? (d['price_per_hour_qar'] as num).toInt()
          : null,
      availability: d['availability'] as String? ?? '',
      formats: List<String>.from((d['formats'] as List?) ?? []),
      ageGroups: List<String>.from((d['age_groups'] as List?) ?? []),
      languages: List<String>.from((d['languages'] as List?) ?? []),
      yearsExperience: (d['years_experience'] as num?)?.toInt() ?? 0,
      credentials: d['credentials'] as String? ?? '',
      avatarUrl: d['avatar_url'] as String? ?? '',
      trialAvailable: d['trial_available'] as bool? ?? false,
      createdAt: _parseDate(d['created_at']),
      updatedAt: _parseDate(d['updated_at']),
    );
  }

  UserRole _parseRole(String? raw) => switch (raw?.toUpperCase()) {
    'TUTOR' => UserRole.tutor,
    'MASTERCLASS' => UserRole.masterclass,
    _ => UserRole.family,
  };

  @override
  Future<String> uploadAvatar(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/provider/avatar/', data: formData);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return (data['avatar_url'] ?? data['url'] ?? '') as String;
      }
      return '';
    } on DioException catch (e) {
      throw StateError(_extractError(e));
    }
  }

  // ── Listings ───────────────────────────────────────────────────────────────

  @override
  Future<List<Listing>> myListings(String providerId) async {
    try {
      final response = await _dio.get('/provider/listings/');
      final data = response.data;
      final items = data is Map<String, dynamic> ? data['results'] : data;
      if (items is! List) return const [];
      return items
          .whereType<Map>()
          .map(
            (item) => ListingParser.fromCard(Map<String, dynamic>.from(item)),
          )
          .toList();
    } on DioException catch (e) {
      throw StateError(_extractError(e));
    }
  }

  @override
  Future<Listing> upsertListing(
    Listing listing, {
    List<String> imagePaths = const [],
  }) async {
    final payload = _serializeListing(listing);
    try {
      final data = imagePaths.isEmpty
          ? payload
          : await _buildListingMultipartData(payload, imagePaths);
      final response = _looksLikeBackendListingId(listing.id)
          ? await _dio.patch('/provider/listings/${listing.id}/', data: data)
          : await _dio.post('/provider/listings/', data: data);
      return ListingParser.fromCard(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw StateError(_extractError(e));
    }
  }

  @override
  Future<Listing> submitForReview(String listingId) async {
    // The backend automatically re-enters PENDING on any save; there is no
    // separate submit endpoint. Re-fetch to return the server's current state.
    try {
      final response = await _dio.get('/provider/listings/$listingId/');
      return ListingParser.fromCard(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw StateError(_extractError(e));
    }
  }

  // ── Inquiries ──────────────────────────────────────────────────────────────

  @override
  Future<List<Inquiry>> incomingInquiries(String providerId) async {
    try {
      final response = await _dio.get('/tutor/inquiries/');
      final data = response.data;
      final items = data is Map<String, dynamic> ? data['results'] : data;
      if (items is! List) return const [];
      return items
          .whereType<Map>()
          .map((item) => _parseInquiry(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (e) {
      throw StateError(_extractError(e));
    }
  }

  @override
  Future<void> markContacted(String inquiryId) async {
    return _patchTransition(inquiryId, InquiryStatus.contacted);
  }

  @override
  Future<void> acceptInquiry(String inquiryId) async {
    return _patchTransition(inquiryId, InquiryStatus.accepted);
  }

  @override
  Future<void> declineInquiry(String inquiryId) async {
    return _patchTransition(inquiryId, InquiryStatus.declined);
  }

  @override
  Future<void> completeInquiry(String inquiryId) async {
    return _patchTransition(inquiryId, InquiryStatus.completed);
  }

  Future<void> _patchTransition(String inquiryId, InquiryStatus status) async {
    try {
      await _dio.patch(
        '/tutor/inquiries/$inquiryId/',
        data: {'status': status.toBackend()},
      );
      return;
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        final msg = _extractError(e);
        throw StateError('409:$msg');
      }
      throw StateError(_extractError(e));
    }
  }

  Inquiry _parseInquiry(Map<String, dynamic> d) {
    final family = d['family'] as Map<String, dynamic>?;
    final tutor = d['tutor'];
    return Inquiry(
      id: d['id'].toString(),
      tutorId: d['tutor_id']?.toString(),
      tutor: tutor is Map
          ? InquiryTutor.fromJson(Map<String, dynamic>.from(tutor))
          : null,
      message: d['message'] as String? ?? '',
      status: InquiryStatus.fromBackend(d['status'] as String?),
      contactRevealed: d['contact_revealed'] as bool? ?? false,
      createdAt: _parseDate(d['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(d['updated_at']),
      familyId: family?['id']?.toString(),
      familyName: family?['full_name'] as String?,
      familyEmail: family?['email'] as String?,
      familyPhone: family?['phone'] as String?,
    );
  }

  // ── Subscriptions (provider roster) ───────────────────────────────────────

  @override
  Future<List<Subscription>> incomingSubscriptions({
    String? listingId,
    SubscriptionStatus? status,
  }) async {
    final queryParams = <String, String>{};
    if (listingId != null) queryParams['listing_id'] = listingId;
    if (status != null) queryParams['status'] = status.toBackend();
    try {
      final response = await _dio.get(
        '/provider/subscriptions/',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );
      final data = response.data;
      final items = data is Map<String, dynamic> ? data['results'] : data;
      if (items is! List) return const [];
      return items
          .whereType<Map>()
          .map(
            (item) =>
                _parseProviderSubscription(Map<String, dynamic>.from(item)),
          )
          .toList();
    } on DioException catch (e) {
      throw StateError(_extractError(e));
    }
  }

  Subscription _parseProviderSubscription(Map<String, dynamic> d) {
    final family = d['family'] as Map<String, dynamic>?;
    return Subscription(
      id: d['id'] as String,
      listingId: d['listing_id'] as String,
      providerId: d['provider_id']?.toString() ?? '',
      status: SubscriptionStatus.fromBackend(d['status'] as String?),
      createdAt: _parseDate(d['created_at']) ?? DateTime.now(),
      cancelledAt: _parseDate(d['cancelled_at']),
      listingTitle: d['listing_title'] as String?,
      familyName: family?['full_name'] as String?,
      familyId: family?['id']?.toString(),
    );
  }

  // ── Earnings ───────────────────────────────────────────────────────────────

  @override
  Future<EarningsSummary> earnings(String providerId) async {
    // Billing is Phase 6 — return empty summary.
    return const EarningsSummary(
      acceptedStudents: 0,
      pendingQar: 0,
      paidQar: 0,
      commissions: [],
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<FormData> _buildListingMultipartData(
    Map<String, dynamic> payload,
    List<String> imagePaths,
  ) async {
    return FormData.fromMap({
      'title': payload['title'],
      'category': payload['category'],
      'subtitle': payload['subtitle'],
      'neighborhood': payload['neighborhood'],
      'lat': payload['lat']?.toString(),
      'lng': payload['lng']?.toString(),
      'price_from_qar': payload['price_from_qar']?.toString(),
      'image_urls': jsonEncode(payload['image_urls'] ?? const []),
      'age_groups': jsonEncode(payload['age_groups'] ?? const []),
      'description': payload['description'],
      'highlights': jsonEncode(payload['highlights'] ?? const []),
      'is_featured': (payload['is_featured'] as bool?) == true
          ? 'true'
          : 'false',
      'images': [
        for (final path in imagePaths) await MultipartFile.fromFile(path),
      ],
    });
  }

  Map<String, dynamic> _serializeListing(Listing listing) {
    return {
      'title': listing.title,
      'category': ListingParser.serializeCategory(listing.category),
      'subtitle': listing.subtitle,
      'neighborhood': listing.neighborhood,
      'lat': listing.lat,
      'lng': listing.lng,
      'price_from_qar': listing.priceFromQar,
      'image_urls': listing.imageUrls,
      'age_groups': listing.ageGroups,
      'description': listing.description,
      'highlights': listing.highlights,
      'is_featured': listing.isFeatured,
    };
  }

  bool _looksLikeBackendListingId(String id) {
    final uuid = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
    );
    return uuid.hasMatch(id);
  }

  DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    try {
      return DateTime.parse(raw as String);
    } catch (_) {
      return null;
    }
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
