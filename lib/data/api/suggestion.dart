import 'package:dio/dio.dart';

import '../models/suggestion.dart';
import '../repositories/suggestion_repository.dart';
import 'api_client.dart';

class HttpSuggestionRepository implements SuggestionRepository {
  Dio get _dio => apiClient.dio;

  @override
  Future<List<Suggestion>> mySuggestions() async {
    final response = await _dio.get('/suggestions/');
    final data = response.data;
    final results = data is Map ? data['results'] as List : data as List;
    return results
        .cast<Map<String, dynamic>>()
        .map(Suggestion.fromJson)
        .toList();
  }

  @override
  Future<Suggestion> submit({
    String? category,
    String? neighborhood,
    required String message,
  }) async {
    final body = <String, dynamic>{'message': message};
    if (category != null && category.isNotEmpty) body['category'] = category;
    if (neighborhood != null && neighborhood.isNotEmpty) {
      body['neighborhood'] = neighborhood;
    }
    final response = await _dio.post('/suggestions/', data: body);
    return Suggestion.fromJson(response.data as Map<String, dynamic>);
  }
}
