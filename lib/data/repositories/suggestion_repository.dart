import '../models/suggestion.dart';

abstract class SuggestionRepository {
  Future<List<Suggestion>> mySuggestions();

  Future<Suggestion> submit({
    String? category,
    String? neighborhood,
    required String message,
  });
}

class MockSuggestionRepository implements SuggestionRepository {
  final List<Suggestion> _store = [];
  int _nextId = 1;

  @override
  Future<List<Suggestion>> mySuggestions() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_store.reversed.toList());
  }

  @override
  Future<Suggestion> submit({
    String? category,
    String? neighborhood,
    required String message,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final suggestion = Suggestion(
      id: _nextId++,
      category: category ?? '',
      neighborhood: neighborhood ?? '',
      message: message,
      status: SuggestionStatus.new_,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _store.add(suggestion);
    return suggestion;
  }
}
