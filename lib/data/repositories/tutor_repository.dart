import '../models/tutor.dart';

// ── Enums & value objects ────────────────────────────────────────────────────

enum TutorSort {
  rating,
  priceLow,
  priceHigh,
  experience,
  newest;

  /// The key the backend expects in the `ordering` query parameter.
  String get backendKey => switch (this) {
    TutorSort.rating => 'rating',
    TutorSort.priceLow => 'price_per_hour_qar',
    TutorSort.priceHigh => '-price_per_hour_qar',
    TutorSort.experience => '-years_experience',
    TutorSort.newest => '-created_at',
  };
}

/// Immutable filter bag used as the family key for the tutor list provider.
/// Mirrors the backend `GET /tutors/` query contract (search / subject /
/// formats / age_groups / languages / price / trial / ordering) so swapping in
/// the HTTP repo is a one-file change.
class TutorsFilter {
  const TutorsFilter({
    this.search,
    this.subject,
    this.formats = const {},
    this.ageGroups = const {},
    this.languages = const {},
    this.priceMin,
    this.priceMax,
    this.trialOnly = false,
    this.city,
    this.sort = TutorSort.rating,
  });

  final String? search;
  final String? subject;
  final Set<TutorFormat> formats;
  final Set<String> ageGroups;
  final Set<String> languages;
  final int? priceMin;
  final int? priceMax;
  final bool trialOnly;

  /// Canonical city value, e.g. `"Doha, QA"`. null = any city.
  final String? city;
  final TutorSort sort;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TutorsFilter &&
        other.search == search &&
        other.subject == subject &&
        _setEquals(other.formats, formats) &&
        _setEquals(other.ageGroups, ageGroups) &&
        _setEquals(other.languages, languages) &&
        other.priceMin == priceMin &&
        other.priceMax == priceMax &&
        other.trialOnly == trialOnly &&
        other.city == city &&
        other.sort == sort;
  }

  @override
  int get hashCode => Object.hash(
    search,
    subject,
    Object.hashAllUnordered(formats),
    Object.hashAllUnordered(ageGroups),
    Object.hashAllUnordered(languages),
    priceMin,
    priceMax,
    trialOnly,
    city,
    sort,
  );
}

bool _setEquals<T>(Set<T> a, Set<T> b) {
  if (a.length != b.length) return false;
  return a.containsAll(b);
}

// ── Exception ────────────────────────────────────────────────────────────────

class TutorException implements Exception {
  const TutorException(this.message);
  final String message;

  @override
  String toString() => 'TutorException: $message';
}

// ── Abstract contract ────────────────────────────────────────────────────────

abstract class TutorRepository {
  Future<List<Tutor>> tutors({
    String? search,
    String? subject,
    Set<TutorFormat> formats = const {},
    Set<String> ageGroups = const {},
    Set<String> languages = const {},
    int? priceMin,
    int? priceMax,
    bool trialOnly = false,
    String? city,
    TutorSort sort = TutorSort.rating,
  });

  Future<List<String>> subjects();
}
