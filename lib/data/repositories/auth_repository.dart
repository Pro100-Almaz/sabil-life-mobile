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

  Future<void> requestPasswordReset({required String email});

  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String password,
    required String password2,
  });

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPassword2,
  });

  Future<AuthUser> me(String token);
  Future<AuthUser> updateHomeLocation({
    required double latitude,
    required double longitude,
  });
  Future<void> logout();
}

class MockAuthRepository implements AuthRepository {
  static const Duration _latency = Duration(milliseconds: 400);

  /// The mock always "sends" this code. Enter it on the verify step.
  static const String _mockCode = '123456';

  /// Pending registrations awaiting code confirmation, keyed by email.
  final Map<String, ({String password, String fullName})> _pending = {};
  final Set<String> _pendingPasswordResets = {};
  AuthUser? _currentUser;

  @override
  Future<AuthSession> login(String email, String password) async {
    await Future<void>.delayed(_latency);
    final user = authenticateMock(email.trim(), password);
    if (user == null) {
      throw const AuthException('Invalid email or password');
    }
    _currentUser = user;
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
    _currentUser = user;
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
    _currentUser = user;
    return user;
  }

  @override
  Future<AuthUser> updateHomeLocation({
    required double latitude,
    required double longitude,
  }) async {
    await Future<void>.delayed(_latency);
    final user = _currentUser;
    if (user == null) throw const AuthException('Session expired');
    final updated = user.copyWith(homeLat: latitude, homeLng: longitude);
    _currentUser = updated;
    return updated;
  }

  @override
  Future<void> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPassword2,
  }) async {
    await Future<void>.delayed(_latency);
    if (oldPassword != 'demo1234') {
      throw const AuthException('Current password is incorrect.');
    }
    if (newPassword != newPassword2) {
      throw const AuthException('Passwords do not match.');
    }
    if (newPassword.length < 8) {
      throw const AuthException('Password must be at least 8 characters.');
    }
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    await Future<void>.delayed(_latency);

    final normalized = email.trim().toLowerCase();

    // Match the real backend: never reveal whether the account exists.
    if (findMockUserByEmail(normalized) != null) {
      _pendingPasswordResets.add(normalized);
    }
  }

  @override
  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String password,
    required String password2,
  }) async {
    await Future<void>.delayed(_latency);

    final normalized = email.trim().toLowerCase();

    if (!_pendingPasswordResets.contains(normalized)) {
      throw const AuthException(
        'Code expired or not found. Please request a new one.',
      );
    }

    if (code != _mockCode) {
      throw const AuthException('Invalid code.');
    }

    if (password != password2) {
      throw const AuthException('Passwords do not match.');
    }

    if (password.length < 8) {
      throw const AuthException('Password must be at least 8 characters.');
    }

    // Add an appropriate mock password-update helper if mock reset behavior is
    // required. The real HTTP implementation does not need this.
    _pendingPasswordResets.remove(normalized);
  }
}
