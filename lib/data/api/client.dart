import 'package:dio/dio.dart';

import '../models/auth_user.dart';
import '../repositories/auth_repository.dart';
import 'api_client.dart';
import 'auth_token_store.dart';

class HttpAuthRepository implements AuthRepository {
  HttpAuthRepository();

  Dio get _dio => apiClient.dio;

  @override
  Future<AuthSession> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login/',
        data: {'email': email, 'password': password},
      );
      final session = _parseSession(response.data);
      await authTokenStore.write(session.token);
      return session;
    } on DioException catch (e) {
      print("Error:");
      print(e);
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
      await authTokenStore.write(session.token);
      return session;
    } on DioException catch (e) {
      print("Error:");
      print(e);
      throw AuthException(_extractError(e));
    }
  }

  @override
  Future<AuthUser> me(String token) async {
    try {
      // Pass token explicitly: restore() calls me() before the store is
      // freshly written, so we cannot rely on the interceptor here.
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
      await _dio.post('/auth/logout/');
    } on DioException {
      // Best-effort; clear local token regardless.
    } finally {
      await authTokenStore.clear();
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
