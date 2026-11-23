import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/state/auth_provider.dart';
import '../../core/state/provider_subscriptions_provider.dart';

class ProviderFollowButton extends ConsumerWidget {
  const ProviderFollowButton({super.key, required this.providerId});
  final String providerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context)!;
    if (providerId.isEmpty ||
        auth.user?.id == providerId ||
        (auth.isAuthenticated && !auth.isFamily)) {
      return const SizedBox.shrink();
    }
    if (!auth.isAuthenticated) {
      return OutlinedButton.icon(
        onPressed: () => context.push('/login'),
        icon: const Icon(Icons.notifications_none),
        label: Text(l10n.followProvider),
      );
    }
    final subscriptions = ref.watch(followedProvidersProvider);
    final busy = ref.watch(providerFollowActionsProvider).contains(providerId);
    return subscriptions.when(
      loading: () => const CircularProgressIndicator(),
      error: (_, _) => TextButton.icon(
        onPressed: () => ref.invalidate(followedProvidersProvider),
        icon: const Icon(Icons.refresh),
        label: Text(l10n.retry),
      ),
      data: (items) {
        final following = items.any((s) => s.providerId == providerId);
        return OutlinedButton.icon(
          onPressed: busy || subscriptions.isLoading
              ? null
              : () async {
                  try {
                    await ref
                        .read(providerFollowActionsProvider.notifier)
                        .setFollowing(providerId, following: !following);
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.followUpdateError)),
                      );
                    }
                  }
                },
          icon: Icon(
            following
                ? Icons.notifications_active_outlined
                : Icons.notifications_none,
          ),
          label: Text(following ? l10n.unfollowProvider : l10n.followProvider),
        );
      },
    );
  }
}
