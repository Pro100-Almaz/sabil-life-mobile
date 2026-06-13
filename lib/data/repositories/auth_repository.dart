import '../mock/mock_users.dart';
import '../models/auth_user.dart';

/// Method shapes match the planned backend (`/auth/login`, `/auth/register`,
/// `/auth/me`, `/auth/logout`). The HTTP swap is a one-class change.
abstract class AuthRepository {
  Future<AuthSession> login(String email, String password);
  Future<AuthSession> register({
    required String email,
    required String password,
    required String fullName,
    UserRole role,
  });
  Future<AuthUser> me(String token);
  Future<void> logout();
}

class MockAuthRepository implements AuthRepository {
  static const Duration _latency = Duration(milliseconds: 400);

  @override
  Future<AuthSession> login(String email, String password) async {
    await Future<void>.delayed(_latency);
    final user = authenticateMock(email.trim(), password);
    if (user == null) {
      throw const AuthException('Invalid email or password');
    }
    return AuthSession(user: user, token: 'mock-${user.id}');
  }

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
    required String fullName,
    UserRole role = UserRole.family,
  }) async {
    await Future<void>.delayed(_latency);
    final normalized = email.trim();
    if (findMockUserByEmail(normalized) != null) {
      throw const AuthException('An account with this email already exists');
    }
    if (password.length < 6) {
      throw const AuthException('Password must be at least 6 characters');
    }
    final user = AuthUser(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      email: normalized,
      fullName: fullName.trim(),
      role: role,
      // New providers land unverified; families are auto-verified.
      isVerified: role == UserRole.family,
    );
    registerMockAccount(user, password);
    return AuthSession(user: user, token: 'mock-${user.id}');
  }

  @override
  Future<AuthUser> me(String token) async {
    if (!token.startsWith('mock-')) {
      throw const AuthException('Invalid token');
    }
    final id = token.substring('mock-'.length);
    final user = findMockUserById(id);
    if (user == null) {
      throw const AuthException('Session expired');
    }
    return user;
  }

  @override
  Future<void> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}
