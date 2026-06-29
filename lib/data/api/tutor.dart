import 'package:dio/dio.dart';

import '../models/tutor.dart';
import '../repositories/tutor_repository.dart';
import 'api_client.dart';
import 'listing_parser.dart';

class HttpTutorRepository implements TutorRepository {
  HttpTutorRepository();

  Dio get _dio => apiClient.dio;

  @override
  Future<List<Tutor>> tutors({
    String? search,
    String? subject,
    Set<TutorFormat> formats = const {},
    Set<String> ageGroups = const {},
    Set<String> languages = const {},
    int? priceMin,
    int? priceMax,
    bool trialOnly = false,
    String? city,
    TutorSort sort = TutorSort.rating,
  }) async {
    try {
      final params = <String, dynamic>{'ordering': sort.backendKey};
      final trimmed = search?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        params['search'] = trimmed;
      }
      if (subject != null) params['subject'] = subject;
      if (formats.isNotEmpty) {
        params['formats'] = formats.map((f) => f.backendKey).join(',');
      }
      if (ageGroups.isNotEmpty) params['age_groups'] = ageGroups.join(',');
      if (languages.isNotEmpty) params['languages'] = languages.join(',');
      if (priceMin != null) params['price_min'] = priceMin;
      if (priceMax != null) params['price_max'] = priceMax;
      if (trialOnly) params['trial_available'] = true;
      if (city != null && city.isNotEmpty) params['city'] = city;

      final response = await _dio.get('/tutors/', queryParameters: params);
      final data = response.data;
      final items = data is Map<String, dynamic>
          ? (data['results'] as List?)
          : data as List?;
      if (items == null) return const [];
      return items
          .whereType<Map>()
          .map((item) => _parseTutor(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        throw const TutorException('Rate limited, try again later');
      }
      throw TutorException(_extractError(e));
    } catch (e) {
      throw TutorException('Failed to load tutors: $e');
    }
  }

  @override
  Future<List<String>> subjects() async {
    try {
      final response = await _dio.get('/subjects/');
      final data = response.data;
      if (data is List) {
        return data.map((item) => item.toString()).toList();
      }
      if (data is Map<String, dynamic>) {
        final results = data['results'] as List?;
        if (results != null) {
          return results.map((item) => item.toString()).toList();
        }
      }
      return const [];
    } on DioException catch (e) {
      throw TutorException(_extractError(e));
    } catch (e) {
      throw TutorException('Failed to load subjects: $e');
    }
  }

  static Tutor _parseTutor(Map<String, dynamic> data) {
    return Tutor(
      id: data['id']?.toString() ?? '',
      name: (data['full_name'] ?? '') as String,
      avatarUrl: (data['avatar_url'] ?? '') as String,
      affiliationListingId: (data['affiliation_listing_id'] ?? '') as String,
      subjects: ListingParser.toStringList(data['subjects']),
      formats: _parseFormats(data['formats']),
      ageGroups: ListingParser.toStringList(data['age_groups']),
      pricePerHourQar: ListingParser.toInt(data['price_per_hour_qar']),
      rating: ListingParser.toDouble(data['rating']),
      reviewCount: ListingParser.toInt(data['review_count']),
      yearsExperience: ListingParser.toInt(data['years_experience']),
      credentials: (data['credentials'] ?? '') as String,
      languages: ListingParser.toStringList(data['languages']),
      trialAvailable: (data['trial_available'] ?? false) as bool,
      bio: (data['bio'] ?? '') as String,
      city: (data['city'] ?? '') as String,
    );
  }

  static List<TutorFormat> _parseFormats(dynamic value) {
    if (value is! List) return const [];
    return value
        .map((item) => _parseFormat(item?.toString()))
        .whereType<TutorFormat>()
        .toList();
  }

  static TutorFormat? _parseFormat(String? raw) => switch (raw?.toUpperCase()) {
    'ONE_ON_ONE' => TutorFormat.oneOnOne,
    'SMALL_GROUP' => TutorFormat.smallGroup,
    'AT_CENTRE' => TutorFormat.atCentre,
    'ONLINE' => TutorFormat.online,
    _ => null,
  };

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      if (data.containsKey('detail')) return data['detail'].toString();
      if (data.containsKey('message')) return data['message'].toString();
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}
