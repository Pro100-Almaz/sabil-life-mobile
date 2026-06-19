class Review {
  const Review({
    required this.id,
    required this.rating,
    required this.text,
    required this.authorName,
    required this.createdAt,
    // Legacy mock fields — kept nullable for backwards compat.
    this.authorId,
    // monthsAgo is derived from createdAt; kept for mock convenience.
    int? monthsAgo,
  }) : _monthsAgo = monthsAgo;

  final String id;
  final int rating;
  final String text;
  final String authorName;
  final DateTime createdAt;
  final String? authorId;
  final int? _monthsAgo;

  /// Backwards-compat getter used by mock-driven widgets.
  String get author => authorName.isEmpty ? 'Anonymous' : authorName;

  int get monthsAgo {
    if (_monthsAgo != null) return _monthsAgo;
    final diff = DateTime.now().difference(createdAt);
    return (diff.inDays / 30).floor().clamp(0, 999);
  }
}
