import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/api/provider_subscriptions.dart';
import '../../data/models/provider_subscription.dart';
import '../../data/repositories/provider_subscription_repository.dart';
import 'auth_provider.dart';

final providerSubscriptionRepositoryProvider =
    Provider<ProviderSubscriptionRepository>(
      (ref) => HttpProviderSubscriptionRepository(),
    );

// Authentication is a dependency so caches and pending operations never cross
// account boundaries, including accounts with multiple roles.
final _subscriptionSessionProvider = Provider(
  (ref) =>
      ref.watch(authProvider.select((s) => (id: s.user?.id, token: s.token))),
);

final followedProvidersProvider =
    AsyncNotifierProvider<FollowedProviders, List<FollowedProvider>>(
      FollowedProviders.new,
    );

/// The authenticated family's follows. Follow / unfollow patch the cached list
/// in place instead of re-downloading every page.
class FollowedProviders extends AsyncNotifier<List<FollowedProvider>> {
  @override
  Future<List<FollowedProvider>> build() async {
    ref.watch(_subscriptionSessionProvider);
    if (!ref.watch(authProvider.select((s) => s.isFamily))) return const [];
    return ref.watch(providerSubscriptionRepositoryProvider).mine();
  }

  void _patch(List<FollowedProvider> Function(List<FollowedProvider>) apply) {
    final current = state.valueOrNull;
    if (current == null) {
      ref.invalidateSelf();
      return;
    }
    state = AsyncData(List.unmodifiable(apply(current)));
  }

  void added(FollowedProvider provider) => _patch(
    (items) => [
      ...items.where((p) => p.providerId != provider.providerId),
      provider,
    ],
  );

  void removed(String providerId) => _patch(
    (items) => items.where((p) => p.providerId != providerId).toList(),
  );
}

final mySubscriberCountProvider = FutureProvider.autoDispose<int>((ref) {
  ref.watch(_subscriptionSessionProvider);
  final user = ref.watch(authProvider.select((s) => s.user));
  if (user == null || !user.hasProviderRole) return 0;
  return ref.watch(providerSubscriptionRepositoryProvider).mySubscriberCount();
});

final providerFollowActionsProvider =
    StateNotifierProvider<ProviderFollowActions, Set<String>>((ref) {
      ref.watch(_subscriptionSessionProvider);
      return ProviderFollowActions(
        ref,
        ref.watch(providerSubscriptionRepositoryProvider),
      );
    });

class ProviderFollowActions extends StateNotifier<Set<String>> {
  ProviderFollowActions(this._ref, this._repository) : super(const {});
  final Ref _ref;
  final ProviderSubscriptionRepository _repository;

  Future<void> setFollowing(
    String providerId, {
    required bool following,
  }) async {
    final auth = _ref.read(authProvider);
    if (!auth.isFamily || auth.user?.id == providerId || providerId.isEmpty) {
      return;
    }
    if (state.contains(providerId)) return;
    state = {...state, providerId};
    try {
      if (following) {
        final provider = await _repository.subscribe(providerId);
        if (mounted) {
          _ref.read(followedProvidersProvider.notifier).added(provider);
        }
      } else {
        await _repository.unsubscribe(providerId);
        if (mounted) {
          _ref.read(followedProvidersProvider.notifier).removed(providerId);
        }
      }
    } finally {
      if (mounted) state = {...state}..remove(providerId);
    }
  }
}
