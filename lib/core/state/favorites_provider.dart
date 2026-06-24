import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api/favorites.dart';
import '../../data/api/favorites_store.dart';
import '../../data/repositories/favorites_repository.dart';
import 'auth_provider.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => HttpFavoritesRepository(),
);

class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier(this._ref, this._repo) : super(const {});

  final Ref _ref;
  final FavoritesRepository _repo;
  bool _isRefreshing = false;

  Future<void> refresh() async {
    if (_isRefreshing) return;

    _isRefreshing = true;
    try {
      if (!_ref.read(authProvider).isAuthenticated) {
        state = await favoritesStore.read();
        return;
      }

      final cachedIds = await favoritesStore.read();
      if (cachedIds.isNotEmpty) {
        final remoteIds = await _repo.listIds();
        final missingIds = cachedIds.difference(remoteIds);
        for (final id in missingIds) {
          await _repo.save(id);
        }
        await favoritesStore.clear();
      }

      state = await _repo.listIds();
    } on FavoritesException {
      // Keep the last-known state if the background sync fails.
    } catch (_) {
      // Keep the last-known state if local cache access fails.
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> loadCached() async {
    try {
      state = await favoritesStore.read();
    } catch (_) {
      state = const {};
    }
  }

  Future<void> toggle(String id) async {
    final previous = state;
    final next = Set<String>.from(previous);
    final removing = next.remove(id);
    if (!removing) {
      next.add(id);
    }
    state = next;

    try {
      if (_ref.read(authProvider).isAuthenticated) {
        if (removing) {
          await _repo.remove(id);
        } else {
          await _repo.save(id);
        }
      } else {
        await favoritesStore.write(next);
      }
    } on FavoritesException {
      state = previous;
      rethrow;
    } catch (_) {
      state = previous;
      throw const FavoritesException('Failed to update saved listings.');
    }
  }

  bool isSaved(String id) => state.contains(id);
}

/// Ids of saved listings. Drives every heart button and the Saved tab.
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<String>>(
  (ref) {
    final notifier = FavoritesNotifier(
      ref,
      ref.watch(favoritesRepositoryProvider),
    );

    ref.listen<AuthState>(authProvider, (previous, next) {
      final wasAuthenticated = previous?.isAuthenticated ?? false;
      final isAuthenticated = next.isAuthenticated;
      final userChanged = previous?.user?.id != next.user?.id;

      if (!isAuthenticated) {
        notifier.loadCached();
        return;
      }
      if (!wasAuthenticated || userChanged) {
        notifier.refresh();
      }
    });

    Future<void>.microtask(notifier.refresh);

    return notifier;
  },
);
