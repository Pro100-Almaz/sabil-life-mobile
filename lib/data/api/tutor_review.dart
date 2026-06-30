import 'package:dio/dio.dart';

import '../models/review.dart';
import '../repositories/review_repository.dart' show ReviewException;
import '../repositories/tutor_review_repository.dart';
import 'api_client.dart';

class HttpTutorReviewRepository implements TutorReviewRepository {
  HttpTutorReviewRepository();

  Dio get _dio => apiClient.dio;

  @override
  Future<List<Review>> forTutor(String tutorId, {int page = 1}) async {
    try {
      final response = await _dio.get(
        '/tutors/$tutorId/reviews/',
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
  Future<Review> create({
    required String tutorId,
    required int rating,
    required String text,
  }) async {
    try {
      final response = await _dio.post(
        '/tutors/$tutorId/reviews/',
        data: {'rating': rating, 'text': text},
      );
      return _parse(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      // Engagement gate / duplicate review: surfaced as a friendly message.
      final gate = _gateMessage(e);
      if (gate != null) throw ReviewException(gate);
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
      final response = await _dio.patch(
        '/tutor-reviews/$reviewId/',
        data: body,
      );
      return _parse(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      final gate = _gateMessage(e);
      if (gate != null) throw ReviewException(gate);
      throw StateError(_extractError(e));
    }
  }

  @override
  Future<void> delete(String reviewId) async {
    try {
      await _dio.delete('/tutor-reviews/$reviewId/');
    } on DioException catch (e) {
      final gate = _gateMessage(e);
      if (gate != null) throw ReviewException(gate);
      throw StateError(_extractError(e));
    }
  }

  /// Extracts a user-facing message from a 400/403/409 (gate, ownership,
  /// duplicate), or null when the response isn't one of those.
  static String? _gateMessage(DioException e) {
    final code = e.response?.statusCode;
    if (code != 400 && code != 403 && code != 409) return null;
    final data = e.response?.data;
    if (data is Map) {
      final nfe = data['non_field_errors'];
      if (nfe is List && nfe.isNotEmpty) return nfe.first.toString();
      if (data.containsKey('detail')) return data['detail'].toString();
    }
    return null;
  }

  static Review _parse(Map<String, dynamic> data) {
    final rawName = data['author_name']?.toString() ?? '';
    return Review(
      id: data['id'].toString(),
      rating: _toInt(data['rating']),
      text: (data['text'] ?? '') as String,
      authorName: rawName.isEmpty ? 'Anonymous' : rawName,
      authorId: data['author_id']?.toString(),
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
