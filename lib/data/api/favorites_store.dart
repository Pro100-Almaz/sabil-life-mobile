import 'package:shared_preferences/shared_preferences.dart';

const String _kFavoritesKey = 'sabil.favorites.cached_ids';

class FavoritesStore {
  const FavoritesStore();

  Future<Set<String>> read() async {
    final prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList(_kFavoritesKey) ?? const <String>[];
    return values.where((value) => value.isNotEmpty).toSet();
  }

  Future<void> write(Set<String> listingIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kFavoritesKey, listingIds.toList()..sort());
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kFavoritesKey);
  }
}

final favoritesStore = FavoritesStore();
