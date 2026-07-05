import 'package:dio/dio.dart';
import '../repositories/device_repository.dart';
import 'api_client.dart';

class HttpDeviceRepository extends DeviceRepository {
  HttpDeviceRepository();

  Dio get _dio => apiClient.dio;

  @override
  Future<void> register({
    required String fcmToken,
    required String platform,
  }) async {
    try {
      await _dio.post(
        "/notifications/devices/",
        data: {'fcm_token': fcmToken, 'platform': platform},
      );
    } on DioException catch (e){
      throw StateError(_extractError(e));
    }
  }

  @override
  Future<void> unregister(String fcmToken) async {
    try {
      await _dio.post(
        "/notifications/devices/unregister/",
        data: {'fcm_token': fcmToken},
      );
    } on DioException catch (e){
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
