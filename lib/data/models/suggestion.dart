enum SuggestionStatus {
  new_,
  reviewed,
  actedOn,
  dismissed;

  static SuggestionStatus fromString(String value) {
    return switch (value.toUpperCase()) {
      'NEW' => SuggestionStatus.new_,
      'REVIEWED' => SuggestionStatus.reviewed,
      'ACTED_ON' => SuggestionStatus.actedOn,
      'DISMISSED' => SuggestionStatus.dismissed,
      _ => SuggestionStatus.new_,
    };
  }

  String toJson() => switch (this) {
    SuggestionStatus.new_ => 'NEW',
    SuggestionStatus.reviewed => 'REVIEWED',
    SuggestionStatus.actedOn => 'ACTED_ON',
    SuggestionStatus.dismissed => 'DISMISSED',
  };
}

class Suggestion {
  const Suggestion({
    required this.id,
    required this.category,
    required this.neighborhood,
    required this.message,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  final int id;

  /// Free-form string: one of the 7 backend category keys or empty string.
  /// Not [CategoryType] — suggestions allow blanks.
  final String category;
  final String neighborhood;
  final String message;
  final SuggestionStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Suggestion.fromJson(Map<String, dynamic> json) {
    return Suggestion(
      id: json['id'] as int,
      category: (json['category'] ?? '') as String,
      neighborhood: (json['neighborhood'] ?? '') as String,
      message: json['message'] as String,
      status: SuggestionStatus.fromString((json['status'] ?? 'NEW') as String),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }
}
