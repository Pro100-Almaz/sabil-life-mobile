import 'package:dio/dio.dart';

import '../models/review.dart';
import '../repositories/review_repository.dart';
import 'api_client.dart';

class HttpReviewRepository implements ReviewRepository {
  HttpReviewRepository();

  Dio get _dio => apiClient.dio;

  @override
  Future<List<Review>> forListing(String listingId, {int page = 1}) async {
    try {
      final response = await _dio.get(
        '/listings/$listingId/reviews/',
        queryParameters: {'page': page},
      );
      final data = response.data;
      final items = data is Map<String, dynamic>
          ? (data['results'] as List? ?? [])
          : (data as List? ?? []);
      return items
          .whereType<Map>()
          .map((item) => _parse(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (e) {
      throw StateError(_extractError(e));
    }
  }

  @override
  Future<List<Review>> myReviews() async {
    try {
      final response = await _dio.get('/reviews/me/');
      final data = response.data;
      final items = data is Map<String, dynamic>
          ? (data['results'] as List? ?? [])
          : (data as List? ?? []);
      return items
          .whereType<Map>()
          .map((item) => _parse(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (e) {
      throw StateError(_extractError(e));
    }
  }

  @override
  Future<Review> create({
    required String listingId,
    required int rating,
    required String text,
  }) async {
    try {
      final response = await _dio.post(
        '/listings/$listingId/reviews/',
        data: {'rating': rating, 'text': text},
      );
      return _parse(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      // Engagement gate: 400 with non_field_errors
      if (e.response?.statusCode == 400 || e.response?.statusCode == 409) {
        final data = e.response?.data;
        if (data is Map) {
          final nfe = data['non_field_errors'];
          if (nfe is List && nfe.isNotEmpty) {
            throw ReviewException(nfe.first.toString());
          }
          if (data.containsKey('detail')) {
            throw ReviewException(data['detail'].toString());
          }
        }
      }
      throw StateError(_extractError(e));
    }
  }

  @override
  Future<Review> update({
    required String reviewId,
    int? rating,
    String? text,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (rating != null) body['rating'] = rating;
      if (text != null) body['text'] = text;
      final response = await _dio.patch('/reviews/$reviewId/', data: body);
      return _parse(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      throw StateError(_extractError(e));
    }
  }

  @override
  Future<void> delete(String reviewId) async {
    try {
      await _dio.delete('/reviews/$reviewId/');
    } on DioException catch (e) {
      throw StateError(_extractError(e));
    }
  }

  static Review _parse(Map<String, dynamic> data) {
    final rawName = data['author_name']?.toString() ?? '';
    return Review(
      id: data['id'].toString(),
      rating: _toInt(data['rating']),
      text: (data['text'] ?? '') as String,
      authorName: rawName.isEmpty ? 'Anonymous' : rawName,
      createdAt:
          DateTime.tryParse(data['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
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
