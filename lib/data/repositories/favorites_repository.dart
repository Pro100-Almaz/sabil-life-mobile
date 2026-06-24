class FavoritesException implements Exception {
  const FavoritesException(this.message);

  final String message;

  @override
  String toString() => 'FavoritesException: $message';
}

abstract class FavoritesRepository {
  Future<Set<String>> listIds();
  Future<void> save(String listingId);
  Future<void> remove(String listingId);
}
