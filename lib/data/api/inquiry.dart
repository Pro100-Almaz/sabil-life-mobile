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
    required String listingId,
    required String familyId,
    required String familyName,
    required String familyEmail,
    required String message,
    String? tutorIdHint,
  }) async {
    // Only listing_id + message go on the wire; family identity comes from token.
    try {
      final response = await _dio.post(
        '/inquiries/',
        data: {'listing_id': listingId, 'message': message},
      );
      return _parseInquiry(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      throw StateError(_extractError(e));
    }
  }

  static Inquiry _parseInquiry(Map<String, dynamic> data) {
    return Inquiry(
      id: data['id'].toString(),
      listingId: data['listing_id']?.toString() ?? '',
      providerId: data['provider_id']?.toString() ?? '',
      message: (data['message'] ?? '') as String,
      status: InquiryStatus.fromBackend(data['status']?.toString()),
      contactRevealed: (data['contact_revealed'] ?? false) as bool,
      createdAt: _parseDate(data['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(data['updated_at']),
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
