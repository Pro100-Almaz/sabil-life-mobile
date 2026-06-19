import 'dart:async';

import 'package:dio/dio.dart';

import 'api_config.dart';
import 'auth_token_store.dart';

/// Shared HTTP client used by all HTTP repository implementations.
///
/// A single [Dio] instance is configured with base URL and timeouts.
/// The interceptor injects the stored Bearer token on every outgoing request
/// and clears the token + fires [onUnauthorized] on any 401 response.
class ApiClient {
  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Only set Authorization if the caller has not already set one.
          if (!options.headers.containsKey('Authorization')) {
            final token = await authTokenStore.read();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // Only fire on the FIRST 401 after a token was present — otherwise
          // the listener's logout() POST would 401 again and loop forever.
          if (error.response?.statusCode == 401 &&
              (await authTokenStore.read()) != null) {
            await authTokenStore.clear();
            _unauthorizedController.add(null);
          }
          handler.next(error);
        },
      ),
    );
  }

  late final Dio _dio;
  final _unauthorizedController = StreamController<void>.broadcast();

  /// The configured [Dio] instance. Use this in HTTP repositories.
  Dio get dio => _dio;

  /// Fires whenever the server returns 401. Consumers should log the user out.
  Stream<void> get onUnauthorized => _unauthorizedController.stream;

  /// Release resources. Call this only when the client is no longer needed.
  void dispose() {
    _unauthorizedController.close();
  }
}

/// Top-level singleton so all repos share one [Dio] instance and one interceptor.
final apiClient = ApiClient();
