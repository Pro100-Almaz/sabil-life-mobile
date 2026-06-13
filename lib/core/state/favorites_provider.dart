import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier() : super(const {});

  void toggle(String id) {
    final next = Set<String>.from(state);
    if (!next.remove(id)) {
      next.add(id);
    }
    state = next;
  }

  bool isSaved(String id) => state.contains(id);
}

/// Ids of saved listings. Drives every heart button and the Saved tab.
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<String>>(
  (ref) => FavoritesNotifier(),
);
