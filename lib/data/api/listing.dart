import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/listing.dart';
import '../repositories/listing_repository.dart';
import 'api_config.dart';

class HttpListingRepository implements ListingRepository{
    HttpProviderRepository()
        : _dio = Dio(
            BaseOptions(
            baseUrl: apiBaseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {'Content-Type': 'application/json'},
            ),
        );

    @override 
    Future<Listing> listingById(String listingId) async{
        try{
            final response = await dio.get(
                '/listings/${listingId}'
            );
            final data = response.data;
            return _parseListing(Map<String, dynamic>.from(data));
        } on DioException catch (e) {
            throw StateError(_extractError(e));
        }
    }  

    @override
    Future<List<Listing>> listings() async{
        try{
            final response = await dio.get(
                '/listings/'
            );
            final data = response.data;
            final items = data is Map<String, dynamic> ? data['results'] : data;
            if (items is! List) return const [];
            return items
                .whereType<Map>()
                .map((item) => _parseListing(Map<String, dynamic>.from(item)))
                .toList();
        } on DioException catch (e) {
            throw StateError(_extractError(e));
        }
    }
    
    @override
    Future<Listing> listingReviews(String listingId);

    Listing _parseListing(Map<String, dynamic> data) {
        return Listing(
        id: data['id'].toString(),
        title: (data['title'] ?? '') as String,
        category: _parseCategory(data['category']?.toString()),
        subtitle: (data['subtitle'] ?? '') as String,
        neighborhood: (data['neighborhood'] ?? '') as String,
        lat: _toDouble(data['lat']),
        lng: _toDouble(data['lng']),
        rating: _toDouble(data['rating']),
        reviewCount: _toInt(data['review_count']),
        priceFromQar: _toInt(data['price_from_qar']),
        imageUrls: _toStringList(data['image_urls']),
        ageGroups: _toStringList(data['age_groups']),
        isFeatured: (data['is_featured'] ?? false) as bool,
        description: (data['description'] ?? '') as String,
        highlights: _toStringList(data['highlights']),
        ownerId: data['owner_id']?.toString(),
        status: _parseStatus(data['status']?.toString()),
        );
    }
}