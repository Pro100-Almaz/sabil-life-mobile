import 'package:dio/dio.dart';

import '../models/listing.dart';
import '../repositories/catalog_repository.dart';
import 'api_client.dart';
import 'listing_parser.dart';

class HttpCatalogRepository implements CatalogRepository {
  HttpCatalogRepository();

  Dio get _dio => apiClient.dio;

  @override
  Future<List<Listing>> listings({
    CategoryType? category,
    String? query,
    int? priceMax,
    String? ageGroup,
    double? lat,
    double? lng,
    double? maxDistanceKm,
    ListingSort? sort,
    int page = 1,
  }) async {
    try {
      final params = <String, dynamic>{'page': page};
      if (category != null) {
        params['category'] = ListingParser.serializeCategory(category);
      }
      if (query != null && query.isNotEmpty) params['search'] = query;
      if (priceMax != null) params['price_max'] = priceMax;
      if (ageGroup != null) params['age_group'] = ageGroup;
      if (lat != null) params['lat'] = lat;
      if (lng != null) params['lng'] = lng;
      if (maxDistanceKm != null) params['max_distance_km'] = maxDistanceKm;
      if (sort != null) params['sort'] = sort.backendKey;

      final response = await _dio.get('/listings/', queryParameters: params);
      final data = response.data;
      final items = data is Map<String, dynamic>
          ? (data['results'] as List?)
          : data as List?;
      if (items == null) return const [];
      return items
          .whereType<Map>()
          .map(
            (item) => ListingParser.fromCard(Map<String, dynamic>.from(item)),
          )
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        throw const CatalogException('Rate limited, try again later');
      }
      throw CatalogException(_extractError(e));
    } catch (e) {
      throw CatalogException('Failed to load listings: $e');
    }
  }

  @override
  Future<Listing> listing(String id) async {
    try {
      final response = await _dio.get('/listings/$id/');
      return ListingParser.fromDetail(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        throw const CatalogException('Rate limited, try again later');
      }
      if (e.response?.statusCode == 404) {
        throw CatalogException('Listing not found: $id');
      }
      throw CatalogException(_extractError(e));
    } catch (e) {
      throw CatalogException('Failed to load listing: $e');
    }
  }

  @override
  Future<List<CategoryCount>> categories() async {
    try {
      final response = await _dio.get('/categories/');
      final data = response.data;
      final items = data is List ? data : <dynamic>[];
      return items.whereType<Map>().map((item) {
        final raw = Map<String, dynamic>.from(item);
        return CategoryCount(
          key: ListingParser.parseCategory(raw['key']?.toString()),
          count: ListingParser.toInt(raw['count']),
        );
      }).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        throw const CatalogException('Rate limited, try again later');
      }
      throw CatalogException(_extractError(e));
    } catch (e) {
      throw CatalogException('Failed to load categories: $e');
    }
  }

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      if (data.containsKey('detail')) return data['detail'].toString();
      if (data.containsKey('message')) return data['message'].toString();
      if (data.isNotEmpty) {
        final first = data.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
        return first.toString();
      }
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}
