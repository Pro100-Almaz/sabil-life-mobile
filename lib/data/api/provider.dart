import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/commission.dart';
import '../models/inquiry.dart';
import '../models/listing.dart';
import '../repositories/provider_repository.dart';
import 'api_config.dart';

class HttpProviderRepository implements ProviderRepository {
    HttpProviderRepository()
        : _dio = Dio(
            BaseOptions(
            baseUrl: apiBaseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {'Content-Type': 'application/json'},
            ),
        );

    static const String _tokenPrefsKey = 'sabil.auth.token';

    final Dio _dio;

    @override
    Future<List<Listing>> myListings(String providerId) async {
        try {
        final response = await _dio.get(
            '/provider/listings/',
            options: await _authorizedOptions(),
        );
        final data = response.data;
        final items = data is Map<String, dynamic> ? data['results'] : data;
        if (items is! List) return const [];
        return items
            .whereType<Map>()
            .map((item) => _parseListing(Map<String, dynamic>.from(item)))
            .toList();
        } on DioException catch (e) {
        throw StateError(_extractError(e));
        }
    }

    @override
    Future<Listing> upsertListing(Listing listing) async {
        final payload = _serializeListing(listing);
        try {
        final response = _looksLikeBackendListingId(listing.id)
            ? await _dio.patch(
                '/provider/listings/${listing.id}/',
                data: payload,
                options: await _authorizedOptions(),
                )
            : await _dio.post(
                '/provider/listings/',
                data: payload,
                options: await _authorizedOptions(),
                );
        return _parseListing(Map<String, dynamic>.from(response.data as Map));
        } on DioException catch (e) {
        throw StateError(_extractError(e));
        }
    }

    @override
    Future<Listing> submitForReview(String listingId) async {
        try {
        final response = await _dio.get(
            '/provider/listings/$listingId/',
            options: await _authorizedOptions(),
        );
        return _parseListing(Map<String, dynamic>.from(response.data as Map));
        } on DioException catch (e) {
        throw StateError(_extractError(e));
        }
    }
    //   Do this after implementing inquiries

    @override
    Future<List<Inquiry>> incomingInquiries(String providerId) {
        throw UnimplementedError(
        'HttpProviderRepository.incomingInquiries is not implemented yet.',
        );
    }

    @override
    Future<Commission> acceptInquiry(String inquiryId) {
        throw UnimplementedError(
        'HttpProviderRepository.acceptInquiry is not implemented yet.',
        );
    }

    @override
    Future<Inquiry> declineInquiry(String inquiryId) {
        throw UnimplementedError(
        'HttpProviderRepository.declineInquiry is not implemented yet.',
        );
    }

    @override
    Future<EarningsSummary> earnings(String providerId) {
        throw UnimplementedError(
        'HttpProviderRepository.earnings is not implemented yet.',
        );
    }

    Future<Options> _authorizedOptions() async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(_tokenPrefsKey);
        if (token == null || token.isEmpty) {
        throw StateError('No auth token found for provider request.');
        }
        return Options(headers: {'Authorization': 'Bearer $token'});
    }

    Listing _parseListing(Map<String, dynamic> data) {
        return Listing(
        id: data['id'].toString(),
        title: (data['title'] ?? '') as String,
        category: _parseCategory(data['category']?.toString()),
        subtitle: (data['subtitle'] ?? '') as String,
        neighborhood: (data['neighborhood'] ?? '') as String,
        lat: _toDouble(data['lat']),
        lng: _toDouble(data['lng']),
        rating: _toDouble(data['rating']),
        reviewCount: _toInt(data['review_count']),
        priceFromQar: _toInt(data['price_from_qar']),
        imageUrls: _toStringList(data['image_urls']),
        ageGroups: _toStringList(data['age_groups']),
        isFeatured: (data['is_featured'] ?? false) as bool,
        description: (data['description'] ?? '') as String,
        highlights: _toStringList(data['highlights']),
        ownerId: data['owner_id']?.toString(),
        status: _parseStatus(data['status']?.toString()),
        );
    }

    Map<String, dynamic> _serializeListing(Listing listing) {
        return {
        'title': listing.title,
        'category': _serializeCategory(listing.category),
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

    CategoryType _parseCategory(String? raw) {
        return switch (raw?.toUpperCase()) {
        'SCHOOLS' => CategoryType.schools,
        'NURSERIES' => CategoryType.nurseries,
        'ACTIVITIES' => CategoryType.activities,
        'ENTERTAINMENT' => CategoryType.entertainment,
        'TUTORING' => CategoryType.tutoring,
        'MASTERCLASSES' => CategoryType.masterclasses,
        'PARTNERSHIPS' => CategoryType.partnerships,
        _ => CategoryType.activities,
        };
    }

    String _serializeCategory(CategoryType category) {
        return switch (category) {
        CategoryType.schools => 'SCHOOLS',
        CategoryType.nurseries => 'NURSERIES',
        CategoryType.activities => 'ACTIVITIES',
        CategoryType.entertainment => 'ENTERTAINMENT',
        CategoryType.tutoring => 'TUTORING',
        CategoryType.masterclasses => 'MASTERCLASSES',
        CategoryType.partnerships => 'PARTNERSHIPS',
        };
    }

    ListingStatus _parseStatus(String? raw) {
        return switch (raw?.toUpperCase()) {
        'DRAFT' => ListingStatus.draft,
        'PENDING' => ListingStatus.pending,
        'ACTIVE' => ListingStatus.active,
        'REJECTED' => ListingStatus.rejected,
        _ => ListingStatus.active,
        };
    }

    List<String> _toStringList(dynamic value) {
        if (value is! List) return const [];
        return value.map((item) => item.toString()).toList();
    }

    int _toInt(dynamic value) {
        if (value is int) return value;
        if (value is double) return value.round();
        return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    double _toDouble(dynamic value) {
        if (value is double) return value;
        if (value is int) return value.toDouble();
        return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    bool _looksLikeBackendListingId(String id) {
        final uuid = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
        );
        return uuid.hasMatch(id);
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
