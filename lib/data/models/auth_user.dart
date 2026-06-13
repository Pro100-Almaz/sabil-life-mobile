enum UserRole { family, tutor, masterclass }

extension UserRoleX on UserRole {
  bool get isProvider => this == UserRole.tutor || this == UserRole.masterclass;
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.isVerified,
  });

  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final bool isVerified;

  bool get isProvider => role.isProvider;
}

/// Result of a successful login/register. Mirrors the backend response so the
/// HTTP swap is a one-file repository change.
class AuthSession {
  const AuthSession({required this.user, required this.token});

  final AuthUser user;
  final String token;
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => 'AuthException: $message';
}
