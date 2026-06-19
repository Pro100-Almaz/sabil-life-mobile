import '../models/lising.dart';

abstract class ListingRepository {
    Future<Listing> listingById(String listingId);

    Future<List<Listing>> listings();

    Future<Listing> listingReviews(String listingId);
}