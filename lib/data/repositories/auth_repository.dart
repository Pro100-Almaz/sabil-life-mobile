import '../mock/mock_users.dart';
import '../models/auth_user.dart';

/// Method shapes match the planned backend (`/auth/login`, `/auth/register`,
/// `/auth/me`, `/auth/logout`). The HTTP swap is a one-class change.
abstract class AuthRepository {
  Future<AuthSession> login(String email, String password);

  /// Step 1 of registration: validate the inputs and email a verification
  /// code. No account is created until the code is confirmed.
  Future<void> requestRegistrationCode({
    required String email,
    required String password,
    required String fullName,
    String phone,
  });

  /// Step 2 of registration: verify the emailed code. On success the account
  /// is created and a session (user + token) is returned.
  Future<AuthSession> confirmRegistration({
    required String email,
    required String code,
  });

  Future<AuthUser> me(String token);
  Future<void> logout();
}

class MockAuthRepository implements AuthRepository {
  static const Duration _latency = Duration(milliseconds: 400);

  /// The mock always "sends" this code. Enter it on the verify step.
  static const String _mockCode = '123456';

  /// Pending registrations awaiting code confirmation, keyed by email.
  final Map<String, ({String password, String fullName})> _pending = {};

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
  Future<void> requestRegistrationCode({
    required String email,
    required String password,
    required String fullName,
    String phone = '',
  }) async {
    await Future<void>.delayed(_latency);
    final normalized = email.trim();
    if (findMockUserByEmail(normalized) != null) {
      throw const AuthException('An account with this email already exists');
    }
    if (password.length < 6) {
      throw const AuthException('Password must be at least 6 characters');
    }
    _pending[normalized] = (password: password, fullName: fullName.trim());
    // A real backend emails the code here; the mock uses [_mockCode].
  }

  @override
  Future<AuthSession> confirmRegistration({
    required String email,
    required String code,
  }) async {
    await Future<void>.delayed(_latency);
    final normalized = email.trim();
    final pending = _pending[normalized];
    if (pending == null) {
      throw const AuthException('Code expired. Please request a new one.');
    }
    if (code != _mockCode) {
      throw const AuthException('Invalid code');
    }
    final user = AuthUser(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      email: normalized,
      fullName: pending.fullName,
      role: UserRole.family,
      isVerified: true,
    );
    registerMockAccount(user, pending.password);
    _pending.remove(normalized);
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
