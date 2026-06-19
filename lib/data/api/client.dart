import 'package:dio/dio.dart';

import '../models/auth_user.dart';
import '../repositories/auth_repository.dart';
import 'api_config.dart';

class HttpAuthRepository implements AuthRepository {
  HttpAuthRepository()
      : _dio = Dio(
          BaseOptions(
            baseUrl: apiBaseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {'Content-Type': 'application/json'},
          ),
        );

  final Dio _dio;
  String? _token;

  @override
  Future<AuthSession> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login/',
        data: {'email': email, 'password': password},
      );
      final session = _parseSession(response.data);
      _token = session.token;
      return session;
    } on DioException catch (e) {
      throw AuthException(_extractError(e));
    }
  }

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
    required String fullName,
    UserRole role = UserRole.family,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register/',
        data: {
          'email': email,
          'password': password,
          'full_name': fullName,
          'role': role.name.toUpperCase(),
        },
      );
      final session = _parseSession(response.data);
      _token = session.token;
      return session;
    } on DioException catch (e) {
      throw AuthException(_extractError(e));
    }
  }

  @override
  Future<AuthUser> me(String token) async {
    try {
      final response = await _dio.get(
        '/auth/me/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return _parseUser(response.data);
    } on DioException catch (e) {
      throw AuthException(_extractError(e));
    }
  }

  @override
  Future<void> logout() async {
    try {
      if (_token != null) {
        await _dio.post(
          '/auth/logout/',
          options: Options(headers: {'Authorization': 'Bearer $_token'}),
        );
      }
    } on DioException {
      // Best-effort; clear local state regardless.
    } finally {
      _token = null;
    }
  }

  AuthSession _parseSession(dynamic data) {
    final user = _parseUser(data['user']);
    final token = data['token'] as String;
    return AuthSession(user: user, token: token);
  }

  AuthUser _parseUser(dynamic data) {
    return AuthUser(
      id: data['id'].toString(),
      email: data['email'] as String,
      fullName: (data['full_name'] ?? data['fullName'] ?? '') as String,
      role: UserRole.values.firstWhere(
        (r) => r.name.toUpperCase() == data['role'].toString().toUpperCase(),
        orElse: () => UserRole.family,
      ),
      isVerified: (data['is_verified'] ?? data['isVerified'] ?? false) as bool,
    );
  }

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
