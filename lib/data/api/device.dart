import 'package:dio/dio.dart';
import '../repositories/device_repository.dart';
import 'api_client.dart';

class HttpDeviceRepository extends DeviceRepository{
    HttpDeviceRepository();

    Dio get _dio => apiClient.dio;

    @override 
    Future<void> register({
        required String fcmToken,
        required String platform,
    }) async{
        try{
            await _dio.post(
                "/notifications/devices/",
                data: {
                    'fcm_token':fcmToken,
                    'platform': platform, 
                }    
            );
        }
        on DioException {}
    }

    @override 
    Future<void> unregister (String fcmToken) async{
        try{
            await _dio.post(
                "/notifications/devices/unregister/",
                data: {'fcm_token': fcmToken},
            );
        }
        on DioException{}
    }

}