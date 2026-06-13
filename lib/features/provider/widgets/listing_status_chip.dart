import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/listing.dart';

class ListingStatusChip extends StatelessWidget {
  const ListingStatusChip({super.key, required this.status});

  final ListingStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (label, color) = switch (status) {
      ListingStatus.draft => (l10n.statusDraft, AppColors.textSecondary),
      ListingStatus.pending => (l10n.statusPending, AppColors.primary),
      ListingStatus.active => (l10n.statusActive, AppColors.success),
      ListingStatus.rejected => (l10n.statusRejected, AppColors.textTertiary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.chip),
        border: Border.all(color: color),
      ),
      child: Text(label, style: AppTypography.small.copyWith(color: color)),
    );
  }
}
