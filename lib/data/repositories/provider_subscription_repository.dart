import '../models/provider_subscription.dart';

abstract class ProviderSubscriptionRepository {
  Future<List<FollowedProvider>> mine();
  Future<FollowedProvider> subscribe(String providerId);
  Future<void> unsubscribe(String providerId);

  /// Always scoped to the authenticated provider; accepts no provider selector.
  Future<int> mySubscriberCount();
}
