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
      throw AuthException(_extractError(e));
    }
  }

  @override
  Future<void> requestRegistrationCode({
    required String email,
    required String password,
    required String fullName,
    String phone = '',
  }) async {
    try {
      await _dio.post(
        '/auth/register/',
        data: {
          'email': email,
          'password': password,
          'full_name': fullName,
          'phone': phone,
        },
      );
    } on DioException catch (e) {
      throw AuthException(_extractError(e));
    }
  }

  @override
  Future<AuthSession> confirmRegistration({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register/verify/',
        data: {'email': email, 'code': code},
      );
      final session = _parseSession(response.data);
      await authTokenStore.write(session.token);
      return session;
    } on DioException catch (e) {
      throw AuthException(_extractError(e));
    }
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    try {
      await _dio.post('/auth/forgot-password/', data: {'email': email.trim()});
    } on DioException catch (e) {
      throw AuthException(_extractError(e));
    }
  }

  @override
  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String password,
    required String password2,
  }) async {
    try {
      await _dio.post(
        '/auth/forgot-password/confirm/',
        data: {
          'email': email.trim(),
          'code': code.trim(),
          'password': password,
          'password2': password2,
        },
      );
    } on DioException catch (e) {
      throw AuthException(_extractError(e));
    }
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPassword2,
  }) async {
    try {
      await _dio.post(
        '/auth/change-password/',
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
          'new_password2': newPassword2,
        },
      );
    } on DioException catch (e) {
      throw AuthException(_extractError(e));
    }
  }

  @override
  Future<void> requestPersonalInformationChange({
    required AuthUser user,
    required String newName,
    required String newEmail,
    required String newPassword,
    required String newPassword2,
  }) async {
    try {
      await _dio.post(
        "/auth/edit-profile/",
        data: {
          "new_name": newName,
          "new_email": newEmail,
          "new_password": newPassword,
          "new_password2": newPassword2,
        },
      );
    } on DioException catch (e) {
      throw AuthException(_extractError(e));
    }
  }

  @override
  Future<AuthUser> confirmPersonalInformationChange({
    required AuthUser user,
    required String code,
  }) async {
    try {
      final response = await _dio.post(
        "/auth/edit-profile/verify/",
        data: {"code": code.trim()},
      );
      return _parseUser(response.data["user"]);
    } on DioException catch (e) {
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
    return AuthUser.fromJson(Map<String, dynamic>.from(data as Map));
  }

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      if (data.containsKey('detail')) return data['detail'].toString();
      if (data.containsKey('message')) return data['message'].toString();
      // DRF field errors, e.g. {"code": ["Invalid code."]} or
      // {"email": ["A user with this email already exists."]}.
      if (data.isNotEmpty) {
        final first = data.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
        if (first is String) return first;
      }
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}
