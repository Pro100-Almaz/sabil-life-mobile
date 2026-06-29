enum TutorFormat {
  oneOnOne,
  smallGroup,
  atCentre,
  online;

  /// The code the backend uses in the `formats` query parameter / payload.
  String get backendKey => switch (this) {
    TutorFormat.oneOnOne => 'ONE_ON_ONE',
    TutorFormat.smallGroup => 'SMALL_GROUP',
    TutorFormat.atCentre => 'AT_CENTRE',
    TutorFormat.online => 'ONLINE',
  };
}

/// An individual tutor. Tutors are person-centric (unlike venue [Listing]s)
/// and are affiliated with one of the tutoring-centre listings.
class Tutor {
  const Tutor({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.affiliationListingId,
    required this.subjects,
    required this.formats,
    required this.ageGroups,
    required this.pricePerHourQar,
    required this.rating,
    required this.reviewCount,
    required this.yearsExperience,
    required this.credentials,
    required this.languages,
    required this.trialAvailable,
    required this.bio,
    this.city = '',
  });

  final String id;
  final String name;
  final String avatarUrl;

  /// Id of the tutoring-centre [Listing] this tutor teaches at.
  final String affiliationListingId;
  final List<String> subjects;
  final List<TutorFormat> formats;
  final List<String> ageGroups;
  final int pricePerHourQar;
  final double rating;
  final int reviewCount;
  final int yearsExperience;

  /// Mock content (e.g. "MSc Mathematics") — not localized, like venue names.
  final String credentials;

  /// Display codes, e.g. ["EN", "AR"].
  final List<String> languages;
  final bool trialAvailable;
  final String bio;

  /// Canonical city value, e.g. `"Doha, QA"` (English name + country code).
  /// Empty when the tutor has no city (e.g. online-only).
  final String city;
}
