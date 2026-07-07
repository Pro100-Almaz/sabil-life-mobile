import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/tutor.dart';
import '../../data/repositories/tutor_repository.dart';
import 'provider_providers.dart';

/// Language codes a tutor can teach in — shared by the provider profile form
/// and the family-facing tutor filter sheet.
const List<String> kTutorLanguages = [
  'EN',
  'AR',
  'RU',
  'FR',
  'ES',
  'DE',
  'ZH',
  'HI',
  'UR',
  'KK',
];

class TutorFilterState {
  const TutorFilterState({
    this.search = '',
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

  /// Free-text search query (empty = no search).
  final String search;

  /// null = all subjects.
  final String? subject;

  /// Empty = any. Multi-select: a tutor must offer at least one selected value.
  final Set<TutorFormat> formats;
  final Set<String> ageGroups;
  final Set<String> languages;

  /// QAR/hour bounds, null = unbounded.
  final int? priceMin;
  final int? priceMax;

  /// Only tutors that offer a trial lesson.
  final bool trialOnly;

  /// Canonical city value, e.g. `"Doha, QA"`. null = any city.
  final String? city;

  /// Result ordering sent to the backend.
  final TutorSort sort;

  bool get hasActiveFilters =>
      formats.isNotEmpty ||
      ageGroups.isNotEmpty ||
      languages.isNotEmpty ||
      priceMin != null ||
      priceMax != null ||
      trialOnly ||
      city != null;

  TutorFilterState copyWith({
    String? search,
    String? Function()? subject,
    Set<TutorFormat>? formats,
    Set<String>? ageGroups,
    Set<String>? languages,
    int? Function()? priceMin,
    int? Function()? priceMax,
    bool? trialOnly,
    String? Function()? city,
    TutorSort? sort,
  }) {
    return TutorFilterState(
      search: search ?? this.search,
      subject: subject != null ? subject() : this.subject,
      formats: formats ?? this.formats,
      ageGroups: ageGroups ?? this.ageGroups,
      languages: languages ?? this.languages,
      priceMin: priceMin != null ? priceMin() : this.priceMin,
      priceMax: priceMax != null ? priceMax() : this.priceMax,
      trialOnly: trialOnly ?? this.trialOnly,
      city: city != null ? city() : this.city,
      sort: sort ?? this.sort,
    );
  }
}

class TutorFilterNotifier extends StateNotifier<TutorFilterState> {
  TutorFilterNotifier() : super(const TutorFilterState());

  void setSearch(String search) => state = state.copyWith(search: search);

  void setSubject(String? subject) =>
      state = state.copyWith(subject: () => subject);

  void setSort(TutorSort sort) => state = state.copyWith(sort: sort);

  /// Apply the multi-select filter groups from the filter sheet at once.
  void applyFilters({
    required Set<TutorFormat> formats,
    required Set<String> ageGroups,
    required Set<String> languages,
    required int? priceMin,
    required int? priceMax,
    required bool trialOnly,
    required String? city,
  }) {
    state = state.copyWith(
      formats: formats,
      ageGroups: ageGroups,
      languages: languages,
      priceMin: () => priceMin,
      priceMax: () => priceMax,
      trialOnly: trialOnly,
      city: () => city,
    );
  }

  void resetFilters() {
    state = state.copyWith(
      formats: const {},
      ageGroups: const {},
      languages: const {},
      priceMin: () => null,
      priceMax: () => null,
      trialOnly: false,
      city: () => null,
    );
  }
}

final tutorFilterProvider =
    StateNotifierProvider<TutorFilterNotifier, TutorFilterState>(
      (ref) => TutorFilterNotifier(),
    );

/// The [TutorsFilter] derived from the current [tutorFilterProvider] state.
/// Exposed so screens can await a real refresh of `tutorListProvider(thisFilter)`.
final tutorsFilterProvider = Provider<TutorsFilter>((ref) {
  final filter = ref.watch(tutorFilterProvider);
  final query = filter.search.trim();
  return TutorsFilter(
    search: query.isEmpty ? null : query,
    subject: filter.subject,
    formats: filter.formats,
    ageGroups: filter.ageGroups,
    languages: filter.languages,
    priceMin: filter.priceMin,
    priceMax: filter.priceMax,
    trialOnly: filter.trialOnly,
    city: filter.city,
    sort: filter.sort,
  );
});

/// Tutors matching the active search/filters, ordered by the backend.
/// Screens watch this and handle loading / error / data.
final filteredTutorsProvider = Provider<AsyncValue<List<Tutor>>>((ref) {
  return ref.watch(tutorListProvider(ref.watch(tutorsFilterProvider)));
});
