/// A single bookable occurrence of a masterclass.
class MasterclassSession {
  const MasterclassSession({required this.start, required this.seatsLeft});

  final DateTime start;
  final int seatsLeft;
}

/// Event-shaped data that masterclass [Listing]s carry on top of the generic
/// venue fields: schedule, duration, seats and participation format.
class MasterclassInfo {
  const MasterclassInfo({
    required this.sessions,
    required this.durationMin,
    required this.sessionsCount,
    required this.parentAndChild,
  });

  final List<MasterclassSession> sessions;
  final int durationMin;

  /// 1 = one-off event; >1 = a course of that many sessions.
  final int sessionsCount;

  /// true = parent participates; false = drop-off.
  final bool parentAndChild;
}
