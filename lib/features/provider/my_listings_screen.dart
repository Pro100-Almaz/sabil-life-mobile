import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/state/auth_provider.dart';
import '../../core/state/provider_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/listing.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_refresh_indicator.dart';
import 'widgets/listing_status_chip.dart';

class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key, required this.interface});

  final ActiveInterface interface;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authProvider).user;
    if (user == null) return const SizedBox.shrink();

    final listingsAsync = ref.watch(myListingsProvider(user.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myListings),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('${interface.basePath}/listings/new'),
          ),
        ],
      ),
      body: AppRefreshIndicator(
        onRefresh: () => ref.refresh(myListingsProvider(user.id).future),
        child: listingsAsync.when(
          loading: () => const RefreshableMessage(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (e, _) => RefreshableMessage(child: Text(e.toString())),
          data: (items) => items.isEmpty
              ? RefreshableMessage(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.inbox_outlined,
                        size: 48,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(l10n.noListingsYet, style: AppTypography.h3),
                      const SizedBox(height: AppSpacing.lg),
                      AppButton(
                        label: l10n.createFirstListing,
                        icon: Icons.add,
                        onPressed: () =>
                            context.push('${interface.basePath}/listings/new'),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, i) =>
                      _ListingRow(listing: items[i], interface: interface),
                ),
        ),
      ),
    );
  }
}

class _ListingRow extends StatelessWidget {
  const _ListingRow({required this.listing, required this.interface});

  final Listing listing;
  final ActiveInterface interface;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () => context.push(
        '${interface.basePath}/listings/edit/${listing.id}',
        extra: listing,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    listing.title,
                    style: AppTypography.h3.copyWith(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ListingStatusChip(status: listing.status),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              listing.subtitle,
              style: AppTypography.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: Text(listing.neighborhood, style: AppTypography.small),
                ),
                GestureDetector(
                  onTap: () => context.push(
                    '${interface.basePath}/listings/clients/${listing.id}',
                    extra: listing,
                  ),
                  child: Text(
                    l10n.viewClients,
                    style: AppTypography.label.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Text(
                  l10n.editListing,
                  style: AppTypography.label.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
