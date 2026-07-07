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
    this.formats = const [],
    this.ageGroups = const [],
    this.languages = const [],
    this.yearsExperience = 0,
    this.credentials = '',
    this.avatarUrl = '',
    this.trialAvailable = false,
    this.city = '',
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
  final List<String> formats;
  final List<String> ageGroups;
  final List<String> languages;
  final int yearsExperience;
  final String credentials;
  final String avatarUrl;
  final bool trialAvailable;

  /// Canonical city value, e.g. `"Doha, QA"` (English name + country code).
  final String city;
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
    List<String>? formats,
    List<String>? ageGroups,
    List<String>? languages,
    int? yearsExperience,
    String? credentials,
    String? avatarUrl,
    bool? trialAvailable,
    String? city,
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
      formats: formats ?? this.formats,
      ageGroups: ageGroups ?? this.ageGroups,
      languages: languages ?? this.languages,
      yearsExperience: yearsExperience ?? this.yearsExperience,
      credentials: credentials ?? this.credentials,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      trialAvailable: trialAvailable ?? this.trialAvailable,
      city: city ?? this.city,
      createdAt: createdAt != null ? createdAt() : this.createdAt,
      updatedAt: updatedAt != null ? updatedAt() : this.updatedAt,
    );
  }
}
