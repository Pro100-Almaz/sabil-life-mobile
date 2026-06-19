import 'dart:async';

import 'package:dio/dio.dart';

import 'api_config.dart';
import 'auth_token_store.dart';

/// Emitted on every HTTP 429 response.
class RateLimitedEvent {
  const RateLimitedEvent({required this.retryAfter, this.path});

  /// Duration parsed from the `Retry-After` header (seconds integer).
  final Duration retryAfter;

  /// The request path that was throttled, for logging.
  final String? path;
}

/// Shared HTTP client used by all HTTP repository implementations.
///
/// A single [Dio] instance is configured with base URL and timeouts.
/// The interceptor injects the stored Bearer token on every outgoing request,
/// clears the token + fires [onUnauthorized] on any 401 response, and emits
/// on [onRateLimited] for any 429 response.
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
          final status = error.response?.statusCode;

          // Only fire on the FIRST 401 after a token was present — otherwise
          // the listener's logout() POST would 401 again and loop forever.
          if (status == 401 && (await authTokenStore.read()) != null) {
            await authTokenStore.clear();
            _unauthorizedController.add(null);
          }

          // 429 — emit event so app-level UI can surface the rate-limit notice.
          // Do NOT auto-retry; let the error propagate to the calling repo.
          if (status == 429) {
            final retryAfterHeader = error.response?.headers.value(
              'Retry-After',
            );
            final seconds = int.tryParse(retryAfterHeader ?? '') ?? 0;
            _rateLimitedController.add(
              RateLimitedEvent(
                retryAfter: Duration(seconds: seconds),
                path: error.requestOptions.path,
              ),
            );
          }

          handler.next(error);
        },
      ),
    );
  }

  late final Dio _dio;
  final _unauthorizedController = StreamController<void>.broadcast();
  final _rateLimitedController = StreamController<RateLimitedEvent>.broadcast();

  /// The configured [Dio] instance. Use this in HTTP repositories.
  Dio get dio => _dio;

  /// Fires whenever the server returns 401. Consumers should log the user out.
  Stream<void> get onUnauthorized => _unauthorizedController.stream;

  /// Fires whenever the server returns 429. Consumers can surface a SnackBar.
  Stream<RateLimitedEvent> get onRateLimited => _rateLimitedController.stream;

  /// Release resources. Call this only when the client is no longer needed.
  void dispose() {
    _unauthorizedController.close();
    _rateLimitedController.close();
  }
}

/// Top-level singleton so all repos share one [Dio] instance and one interceptor.
final apiClient = ApiClient();
