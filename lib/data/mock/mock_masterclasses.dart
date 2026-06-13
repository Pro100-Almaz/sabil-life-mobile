import '../models/masterclass_info.dart';

/// Next occurrence of [weekday] strictly after today, plus [weeksAhead].
DateTime _upcoming(int weekday, int hour, int minute, {int weeksAhead = 0}) {
  final now = DateTime.now();
  var delta = (weekday - now.weekday) % 7;
  if (delta == 0) delta = 7;
  final day = DateTime(
    now.year,
    now.month,
    now.day,
  ).add(Duration(days: delta + weeksAhead * 7));
  return DateTime(day.year, day.month, day.day, hour, minute);
}

/// Event data per masterclass listing id (see mock_listings.dart).
/// Sessions are generated relative to "today" so the page always shows a
/// believable upcoming schedule.
final Map<String, MasterclassInfo> mockMasterclassInfo = {
  'master-canvas': MasterclassInfo(
    sessions: [
      MasterclassSession(
        start: _upcoming(DateTime.saturday, 10, 0),
        seatsLeft: 6,
      ),
      MasterclassSession(
        start: _upcoming(DateTime.sunday, 15, 0),
        seatsLeft: 3,
      ),
      MasterclassSession(
        start: _upcoming(DateTime.saturday, 10, 0, weeksAhead: 1),
        seatsLeft: 12,
      ),
    ],
    durationMin: 90,
    sessionsCount: 1,
    parentAndChild: true,
  ),
  'master-clayhouse': MasterclassInfo(
    sessions: [
      MasterclassSession(
        start: _upcoming(DateTime.saturday, 11, 0),
        seatsLeft: 4,
      ),
      MasterclassSession(
        start: _upcoming(DateTime.wednesday, 16, 30),
        seatsLeft: 8,
      ),
      MasterclassSession(
        start: _upcoming(DateTime.saturday, 11, 0, weeksAhead: 1),
        seatsLeft: 10,
      ),
    ],
    durationMin: 120,
    sessionsCount: 6,
    parentAndChild: false,
  ),
  'master-littlechefs': MasterclassInfo(
    sessions: [
      MasterclassSession(
        start: _upcoming(DateTime.sunday, 10, 30),
        seatsLeft: 2,
      ),
      MasterclassSession(
        start: _upcoming(DateTime.thursday, 16, 0),
        seatsLeft: 5,
      ),
      MasterclassSession(
        start: _upcoming(DateTime.saturday, 14, 0, weeksAhead: 1),
        seatsLeft: 9,
      ),
    ],
    durationMin: 90,
    sessionsCount: 1,
    parentAndChild: true,
  ),
};
