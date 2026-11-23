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

enum ProviderListingsSection { regular, masterclasses }

class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({
    super.key,
    required this.interface,
    required this.section,
  });

  final ActiveInterface interface;
  final ProviderListingsSection section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authProvider).user;
    if (user == null) return const SizedBox.shrink();

    final listingsAsync = ref.watch(myListingsProvider(user.id));
    final isMasterclasses = section == ProviderListingsSection.masterclasses;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isMasterclasses ? l10n.catMasterclasses : l10n.regularListings,
        ),
        actions: [
          if (isMasterclasses)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: l10n.createMasterclass,
              onPressed: () =>
                  context.push('${interface.basePath}/masterclasses/new'),
            )
          else
            IconButton(
              icon: const Icon(Icons.add_business_outlined),
              tooltip: l10n.claimListing,
              onPressed: () =>
                  context.push('${interface.basePath}/listings/claim'),
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
          data: (items) {
            final filtered = items
                .where(
                  (listing) => isMasterclasses
                      ? listing.category == CategoryType.masterclasses
                      : listing.category != CategoryType.masterclasses,
                )
                .toList();
            return filtered.isEmpty
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
                        Text(
                          isMasterclasses
                              ? l10n.noMasterclassesYet
                              : l10n.noRegularListingsYet,
                          style: AppTypography.h3,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppButton(
                          label: isMasterclasses
                              ? l10n.createMasterclass
                              : l10n.claimListing,
                          icon: isMasterclasses
                              ? Icons.add
                              : Icons.add_business_outlined,
                          onPressed: () => context.push(
                            isMasterclasses
                                ? '${interface.basePath}/masterclasses/new'
                                : '${interface.basePath}/listings/claim',
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, i) => _ListingRow(
                      listing: filtered[i],
                      interface: interface,
                      section: section,
                    ),
                  );
          },
        ),
      ),
    );
  }
}

class _ListingRow extends StatelessWidget {
  const _ListingRow({
    required this.listing,
    required this.interface,
    required this.section,
  });

  final Listing listing;
  final ActiveInterface interface;
  final ProviderListingsSection section;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () => context.push(
        '${interface.basePath}/${section == ProviderListingsSection.masterclasses ? 'masterclasses' : 'listings'}/edit/${listing.id}',
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
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(Icons.event_outlined),
                label: Text(l10n.listingEvents),
                onPressed: () =>
                    context.push('${interface.basePath}/events/${listing.id}'),
              ),
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
