import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock/mock_listings.dart';
import '../../data/mock/mock_masterclasses.dart';
import '../../data/models/listing.dart';
import '../../data/models/masterclass_info.dart';

enum DateWindow { all, thisWeekend, nextWeek }

/// Active date-window chip on the Masterclasses page.
final dateWindowProvider = StateProvider<DateWindow>((ref) => DateWindow.all);

/// Selected session index per masterclass listing (detail "Pick a date").
class SelectedSessionsNotifier extends StateNotifier<Map<String, int>> {
  SelectedSessionsNotifier() : super(const {});

  void select(String listingId, int sessionIndex) =>
      state = {...state, listingId: sessionIndex};
}

final selectedSessionProvider =
    StateNotifierProvider<SelectedSessionsNotifier, Map<String, int>>(
      (ref) => SelectedSessionsNotifier(),
    );

/// Start of the upcoming (or current) Friday–Sunday weekend block.
DateTime _weekendStart(DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final sinceFriday = (now.weekday - DateTime.friday) % 7;
  if (sinceFriday <= 2) {
    return today.subtract(Duration(days: sinceFriday));
  }
  return today.add(Duration(days: (DateTime.friday - now.weekday) % 7));
}

DateWindow windowFor(DateTime session, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final weekendStart = _weekendStart(reference);
  final weekendEnd = weekendStart.add(const Duration(days: 3));
  final nextWeekEnd = weekendEnd.add(const Duration(days: 7));

  if (!session.isBefore(weekendStart) && session.isBefore(weekendEnd)) {
    return DateWindow.thisWeekend;
  }
  if (session.isBefore(nextWeekEnd)) {
    return DateWindow.nextWeek;
  }
  return DateWindow.all; // rendered under "Later"
}

class MasterclassEntry {
  const MasterclassEntry({required this.listing, required this.info});

  final Listing listing;
  final MasterclassInfo info;

  /// Future sessions only, soonest first.
  List<MasterclassSession> get upcomingSessions {
    final now = DateTime.now();
    final upcoming = info.sessions.where((s) => s.start.isAfter(now)).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    return upcoming;
  }
}

/// Masterclass listings joined with their event info, filtered by the
/// active date window and ordered by their next upcoming session.
final masterclassEntriesProvider = Provider<List<MasterclassEntry>>((ref) {
  final window = ref.watch(dateWindowProvider);

  final entries = <MasterclassEntry>[];
  for (final listing in mockListings) {
    if (listing.category != CategoryType.masterclasses) continue;
    final info = mockMasterclassInfo[listing.id];
    if (info == null) continue;
    final entry = MasterclassEntry(listing: listing, info: info);
    if (entry.upcomingSessions.isEmpty) continue;
    if (window != DateWindow.all &&
        !entry.upcomingSessions.any((s) => windowFor(s.start) == window)) {
      continue;
    }
    entries.add(entry);
  }

  entries.sort(
    (a, b) => a.upcomingSessions.first.start.compareTo(
      b.upcomingSessions.first.start,
    ),
  );
  return entries;
});
