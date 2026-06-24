import 'package:dio/dio.dart';

import '../repositories/favorites_repository.dart';
import 'api_client.dart';

class HttpFavoritesRepository implements FavoritesRepository {
  HttpFavoritesRepository();

  Dio get _dio => apiClient.dio;

  @override
  Future<Set<String>> listIds() async {
    try {
      final response = await _dio.get('/favorites/');
      final data = response.data;
      final items = data is Map<String, dynamic>
          ? (data['results'] as List?)
          : data as List?;
      return items
              ?.whereType<Map>()
              .map((item) => item['listing']?.toString())
              .whereType<String>()
              .toSet() ??
          <String>{};
    } on DioException catch (e) {
      throw FavoritesException(_extractError(e));
    } catch (e) {
      throw FavoritesException('Failed to load favorites: $e');
    }
  }

  @override
  Future<void> save(String listingId) async {
    try {
      await _dio.post('/favorites/', data: {'listing': listingId});
    } on DioException catch (e) {
      throw FavoritesException(_extractError(e));
    } catch (e) {
      throw FavoritesException('Failed to save favorite: $e');
    }
  }

  @override
  Future<void> remove(String listingId) async {
    try {
      await _dio.delete('/favorites/$listingId/');
    } on DioException catch (e) {
      throw FavoritesException(_extractError(e));
    } catch (e) {
      throw FavoritesException('Failed to remove favorite: $e');
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
