import 'package:dio/dio.dart';
import '../models/provider_subscription.dart';
import '../repositories/provider_subscription_repository.dart';
import 'api_client.dart';

class HttpProviderSubscriptionRepository
    implements ProviderSubscriptionRepository {
  HttpProviderSubscriptionRepository({Dio? dio}) : _dio = dio ?? apiClient.dio;
  final Dio _dio;

  @override
  Future<List<FollowedProvider>> mine() async {
    final providers = <String, FollowedProvider>{};
    var page = 1;
    bool hasNext;
    do {
      final response = await _dio.get(
        '/provider-subscriptions/',
        queryParameters: {'page': page},
      );
      final data = response.data as Map;
      for (final item in data['results'] as List) {
        final subscription = FollowedProvider.fromJson(
          Map<String, dynamic>.from(item as Map),
        );
        providers[subscription.providerId] = subscription;
      }
      hasNext = data['next'] != null;
      page++;
    } while (hasNext);
    return List.unmodifiable(providers.values);
  }

  @override
  Future<FollowedProvider> subscribe(String providerId) async {
    final response = await _dio.post(
      '/provider-subscriptions/',
      data: {'provider_id': providerId},
    );
    return FollowedProvider.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  @override
  Future<void> unsubscribe(String providerId) async {
    try {
      await _dio.delete(
        '/provider-subscriptions/${Uri.encodeComponent(providerId)}/',
      );
    } on DioException catch (e) {
      // Another device may already have removed this follow.
      if (e.response?.statusCode != 404) rethrow;
    }
  }

  @override
  Future<int> mySubscriberCount() async {
    final response = await _dio.get('/provider/subscribers/count/');
    return (response.data['count'] as num).toInt();
  }
}
