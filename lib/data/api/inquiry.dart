import 'package:dio/dio.dart';

import '../models/inquiry.dart';
import '../repositories/inquiry_repository.dart';
import 'api_client.dart';

class HttpInquiryRepository implements InquiryRepository {
  HttpInquiryRepository();

  Dio get _dio => apiClient.dio;

  @override
  Future<List<Inquiry>> myInquiries(String familyId) async {
    // familyId is ignored — backend reads family from the token.
    try {
      final response = await _dio.get('/inquiries/');
      final data = response.data;
      final items = data is Map<String, dynamic>
          ? (data['results'] as List? ?? [])
          : (data as List? ?? []);
      return items
          .whereType<Map>()
          .map((item) => _parseInquiry(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (e) {
      throw StateError(_extractError(e));
    }
  }

  @override
  Future<Inquiry> create({
    required String tutorId,
    required String message,
  }) async {
    // Only tutor_id + message go on the wire; family identity comes from token.
    try {
      final response = await _dio.post(
        '/inquiries/',
        data: {
          'tutor_id': int.tryParse(tutorId) ?? tutorId,
          'message': message,
        },
      );
      return _parseInquiry(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      throw StateError(_extractError(e));
    }
  }

  @override
  Future<Inquiry> cancel(String inquiryId) async {
    try {
      final response = await _dio.post(
        '/inquiries/$inquiryId/cancel/',
        data: null,
      );
      return _parseInquiry(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      throw StateError(_extractError(e));
    }
  }

  static Inquiry _parseInquiry(Map<String, dynamic> data) {
    final tutor = data['tutor'];
    final review = data['review'];
    return Inquiry(
      id: data['id'].toString(),
      tutorId: data['tutor_id']?.toString(),
      tutor: tutor is Map
          ? InquiryTutor.fromJson(Map<String, dynamic>.from(tutor))
          : null,
      message: (data['message'] ?? '') as String,
      status: InquiryStatus.fromBackend(data['status']?.toString()),
      contactRevealed: (data['contact_revealed'] ?? false) as bool,
      createdAt: _parseDate(data['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(data['updated_at']),
      // `review` is `{}` (no review yet) or `{id, rating, text}`.
      review: review is Map && review['id'] != null
          ? InquiryReview.fromJson(Map<String, dynamic>.from(review))
          : null,
    );
  }

  static DateTime? _parseDate(dynamic raw) {
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
