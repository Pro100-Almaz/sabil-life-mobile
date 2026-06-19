import 'auth_user.dart';

class ProviderProfile {
  const ProviderProfile({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.role,
    required this.isVerified,
    required this.displayName,
    required this.bio,
    required this.subjects,
    this.hourlyRateQar,
    required this.availability,
    this.createdAt,
    this.updatedAt,
  });

  final int userId;
  final String email;
  final String fullName;
  final UserRole role;
  final bool isVerified;
  final String displayName;
  final String bio;
  final List<String> subjects;
  final int? hourlyRateQar;
  final String availability;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProviderProfile copyWith({
    int? userId,
    String? email,
    String? fullName,
    UserRole? role,
    bool? isVerified,
    String? displayName,
    String? bio,
    List<String>? subjects,
    int? Function()? hourlyRateQar,
    String? availability,
    DateTime? Function()? createdAt,
    DateTime? Function()? updatedAt,
  }) {
    return ProviderProfile(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      subjects: subjects ?? this.subjects,
      hourlyRateQar: hourlyRateQar != null
          ? hourlyRateQar()
          : this.hourlyRateQar,
      availability: availability ?? this.availability,
      createdAt: createdAt != null ? createdAt() : this.createdAt,
      updatedAt: updatedAt != null ? updatedAt() : this.updatedAt,
    );
  }
}
