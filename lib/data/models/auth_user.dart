import 'package:latlong2/latlong.dart';

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
    this.roles = const {},
    this.homeLat,
    this.homeLng,
  });

  factory AuthUser.fromJson(Map<String, dynamic> data) {
    final roles = (data['roles'] as List? ?? const [])
        .map((role) => role.toString().toUpperCase())
        .toSet();
    final legacyRole = data['role']?.toString().toUpperCase();
    if (roles.isEmpty && legacyRole != null) roles.add(legacyRole);

    final primaryRole = roles.contains('FAMILY')
        ? UserRole.family
        : roles.contains('TUTOR')
        ? UserRole.tutor
        : roles.contains('MASTERCLASS')
        ? UserRole.masterclass
        : UserRole.family;

    return AuthUser(
      id: data['id'].toString(),
      email: data['email'] as String,
      fullName: (data['full_name'] ?? data['fullName'] ?? '') as String,
      role: primaryRole,
      isVerified: (data['is_verified'] ?? data['isVerified'] ?? false) as bool,
      roles: roles,
      homeLat: (data['home_lat'] as num?)?.toDouble(),
      homeLng: (data['home_lng'] as num?)?.toDouble(),
    );
  }

  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final bool isVerified;
  final Set<String> roles;
  final double? homeLat;
  final double? homeLng;

  LatLng? get homeLocation =>
      homeLat != null && homeLng != null ? LatLng(homeLat!, homeLng!) : null;

  AuthUser copyWith({double? homeLat, double? homeLng}) => AuthUser(
    id: id,
    email: email,
    fullName: fullName,
    role: role,
    isVerified: isVerified,
    roles: roles,
    homeLat: homeLat ?? this.homeLat,
    homeLng: homeLng ?? this.homeLng,
  );

  bool get isProvider => role.isProvider;
  bool get isFamily => roles.isEmpty
      ? role == UserRole.family
      : roles.contains(UserRole.family.name.toUpperCase());
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
