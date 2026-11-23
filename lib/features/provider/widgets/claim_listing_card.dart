import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/listing.dart';

/// A directory listing the provider can request ownership of.
class ClaimListingCard extends StatelessWidget {
  const ClaimListingCard({
    super.key,
    required this.listing,
    required this.requested,
    required this.claiming,
    required this.onClaim,
  });

  final Listing listing;

  /// A pending request for this listing already exists.
  final bool requested;

  /// This listing's request is in flight.
  final bool claiming;

  /// Null disables the button (another request is in flight).
  final VoidCallback? onClaim;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
            child: requested
                ? OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.hourglass_top_outlined),
                    label: Text(l10n.ownershipRequested),
                  )
                : FilledButton.icon(
                    onPressed: onClaim,
                    icon: claiming
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
  }
}
