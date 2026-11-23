import 'package:dio/dio.dart';
import '../models/listing_event.dart';
import '../repositories/event_repository.dart';
import 'api_client.dart';

class HttpEventRepository implements EventRepository {
  HttpEventRepository({Dio? dio}) : _dio = dio ?? apiClient.dio;
  final Dio _dio;

  @override
  Future<EventPage> forListing(
    String listingId, {
    int page = 1,
    bool owned = false,
  }) async {
    final response = await _dio.get(
      '/${owned ? 'provider/' : ''}listings/$listingId/events/',
      queryParameters: {'page': page},
      // Public discovery must also work with an expired stored token.
      options: owned ? null : Options(extra: {'anonymous': true}),
    );
    final data = response.data as Map;
    return EventPage(
      results: (data['results'] as List)
          .map(
            (e) => ListingEvent.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
      hasNext: data['next'] != null,
    );
  }

  @override
  Future<ListingEvent> publish(
    String listingId,
    Map<String, dynamic> fields,
  ) async {
    final response = await _dio.post(
      '/provider/listings/$listingId/events/',
      data: fields,
    );
    return ListingEvent.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }
}
