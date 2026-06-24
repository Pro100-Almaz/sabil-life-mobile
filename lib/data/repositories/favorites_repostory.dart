import '../models/listing.dart';

abstract class FavortiesRepository {
  Future<List<Listing>> myFavorites(String userId);
  Future<bool> addFavorite(String listingId);
  Future<bool> deleteFavorite(String listingId);
}
