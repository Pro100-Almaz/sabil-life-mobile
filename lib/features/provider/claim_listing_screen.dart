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
import '../../data/repositories/catalog_repository.dart';
import '../../shared/widgets/app_refresh_indicator.dart';

/// Directory listings are created by the platform. Providers can request to
/// take ownership, then edit the listing after that request is approved.
class ClaimListingScreen extends ConsumerStatefulWidget {
  const ClaimListingScreen({super.key});

  @override
  ConsumerState<ClaimListingScreen> createState() => _ClaimListingScreenState();
}

class _ClaimListingScreenState extends ConsumerState<ClaimListingScreen> {
  String? _claimingId;

  Future<void> _claim(Listing listing) async {
    setState(() => _claimingId = listing.id);
    try {
      await ref
          .read(providerRepositoryProvider)
          .requestListingOwnership(listing.id);
      ref.invalidate(myOwnershipRequestsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.ownershipRequestSent),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$error')));
    } finally {
      if (mounted) setState(() => _claimingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authProvider).user;
    final listings = ref.watch(
      catalogListingsProvider(const ListingsFilter(sort: ListingSort.rating)),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.claimListing),
        actions: [
          IconButton(
            tooltip: 'Ownership requests',
            icon: const Icon(Icons.history_outlined),
            onPressed: () =>
                context.push('/provider/masterclass/listings/requests'),
          ),
        ],
      ),
      body: AppRefreshIndicator(
        onRefresh: () => ref.refresh(
          catalogListingsProvider(
            const ListingsFilter(sort: ListingSort.rating),
          ).future,
        ),
        child: listings.when(
          loading: () => const RefreshableMessage(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (error, _) =>
              RefreshableMessage(child: Text(error.toString())),
          data: (page) {
            final available = page.results
                .where(
                  (listing) =>
                      listing.category != CategoryType.masterclasses &&
                      listing.ownerId != user?.id,
                )
                .toList();
            if (available.isEmpty) {
              return RefreshableMessage(child: Text(l10n.noListingsYet));
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: available.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final listing = available[index];
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(listing.title, style: AppTypography.h3),
                      const SizedBox(height: AppSpacing.xs),
                      Text(listing.subtitle, style: AppTypography.caption),
                      const SizedBox(height: AppSpacing.xs),
                      Text(listing.neighborhood, style: AppTypography.small),
                      const SizedBox(height: AppSpacing.md),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          onPressed: _claimingId == null
                              ? () => _claim(listing)
                              : null,
                          icon: _claimingId == listing.id
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.add_business_outlined),
                          label: Text(l10n.requestOwnership),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
