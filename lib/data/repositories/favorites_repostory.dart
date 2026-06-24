impor '../models/listing.dart'

abstract class FavortiesRepository{
    Future<List<Listing>> my_favorites(required userId);
    Future<bool> add_favorite(required String listingId);
    Future<bool> delete_favorite(required String listingId);
} 