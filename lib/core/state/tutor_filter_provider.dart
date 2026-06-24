import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/tutor.dart';
import 'provider_providers.dart';

class TutorFilterState {
  const TutorFilterState({this.subject, this.formats = const {}});

  /// null = all subjects.
  final String? subject;

  /// Empty = any format. Multiple selected formats must ALL be offered.
  final Set<TutorFormat> formats;

  TutorFilterState copyWith({
    String? Function()? subject,
    Set<TutorFormat>? formats,
  }) {
    return TutorFilterState(
      subject: subject != null ? subject() : this.subject,
      formats: formats ?? this.formats,
    );
  }
}

class TutorFilterNotifier extends StateNotifier<TutorFilterState> {
  TutorFilterNotifier() : super(const TutorFilterState());

  void setSubject(String? subject) =>
      state = state.copyWith(subject: () => subject);

  void toggleFormat(TutorFormat format) {
    final next = Set<TutorFormat>.from(state.formats);
    if (!next.remove(format)) {
      next.add(format);
    }
    state = state.copyWith(formats: next);
  }
}

final tutorFilterProvider =
    StateNotifierProvider<TutorFilterNotifier, TutorFilterState>(
      (ref) => TutorFilterNotifier(),
    );

/// Tutors matching the active subject/format filters, top-rated first.
final filteredTutorsProvider = Provider<AsyncValue<List<Tutor>>>((ref) {
  final filter = ref.watch(tutorFilterProvider);
  final asyncTutors = ref.watch(allTutorsProvider);

  return asyncTutors.whenData((tutors) {
    final result = tutors.where((tutor) {
      if (filter.subject != null && !tutor.subjects.contains(filter.subject)) {
        return false;
      }
      for (final format in filter.formats) {
        if (!tutor.formats.contains(format)) return false;
      }
      return true;
    }).toList()..sort((a, b) => b.rating.compareTo(a.rating));

    return result;
  });
});
