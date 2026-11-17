import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/state/auth_provider.dart';
import '../../core/state/provider_subscriptions_provider.dart';
import '../../shared/widgets/app_refresh_indicator.dart';
import 'provider_follow_button.dart';

class FollowedProvidersScreen extends ConsumerWidget {
  const FollowedProvidersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isFamily = ref.watch(authProvider.select((s) => s.isFamily));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.followedProviders)),
      body: !isFamily
          ? const SizedBox.shrink()
          : AppRefreshIndicator(
              onRefresh: () => ref.refresh(followedProvidersProvider.future),
              child: ref
                  .watch(followedProvidersProvider)
                  .when(
                    loading: () => const RefreshableMessage(
                      child: CircularProgressIndicator(),
                    ),
                    error: (_, _) => RefreshableMessage(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(l10n.genericLoadError),
                          TextButton(
                            onPressed: () =>
                                ref.invalidate(followedProvidersProvider),
                            child: Text(l10n.retry),
                          ),
                        ],
                      ),
                    ),
                    data: (items) => items.isEmpty
                        ? RefreshableMessage(
                            child: Text(l10n.noFollowedProviders),
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: items.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) => ListTile(
                              leading: const Icon(Icons.person_outline),
                              title: Text(items[index].displayName),
                              trailing: ProviderFollowButton(
                                providerId: items[index].providerId,
                              ),
                            ),
                          ),
                  ),
            ),
    );
  }
}
