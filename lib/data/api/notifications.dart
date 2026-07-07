import 'package:dio/dio.dart';

import '../models/app_notification.dart';
import '../repositories/notification_repository.dart';
import 'api_client.dart';

class HttpNotificationRepository implements NotificationRepository {
  HttpNotificationRepository();

  Dio get _dio => apiClient.dio;

  @override
  Future<List<AppNotification>> getNotifications() async {
    try {
      final response = await _dio.get('/notifications/');
      // The list endpoint is paginated: { count, next, previous, results }.
      final results = (response.data['results'] as List?) ?? const [];
      return results
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw StateError(_extractError(e));
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get('/notifications/unread-count/');
      return (response.data['unread'] as num?)?.toInt() ?? 0;
    } on DioException catch (e) {
      throw StateError(_extractError(e));
    }
  }

  @override
  Future<void> postNotificationRead(int id) async {
    try {
      // Backend returns {"updated": <count>}; nothing to parse.
      await _dio.post('/notifications/$id/read/');
    } on DioException catch (e) {
      throw StateError(_extractError(e));
    }
  }

  @override
  Future<void> postNotificationReadAll() async {
    try {
      await _dio.post('/notifications/read-all/');
    } on DioException catch (e) {
      throw StateError(_extractError(e));
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
