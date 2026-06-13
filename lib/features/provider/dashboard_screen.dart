import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/state/auth_provider.dart';
import '../../core/state/provider_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/inquiry.dart';
import '../../data/models/listing.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);
    final user = auth.user;
    if (user == null) return const SizedBox.shrink();

    final listingsAsync = ref.watch(myListingsProvider(user.id));
    final inquiriesAsync = ref.watch(incomingInquiriesProvider(user.id));
    final earningsAsync = ref.watch(earningsProvider(user.id));

    final activeListings = listingsAsync.maybeWhen(
      data: (items) =>
          items.where((l) => l.status == ListingStatus.active).length,
      orElse: () => 0,
    );
    final newInquiries = inquiriesAsync.maybeWhen(
      data: (items) =>
          items.where((i) => i.status == InquiryStatus.pending).length,
      orElse: () => 0,
    );
    final pendingCommission = earningsAsync.maybeWhen(
      data: (summary) => summary.pendingQar,
      orElse: () => 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.welcomeBack(user.fullName)),
        toolbarHeight: 72,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          if (!user.isVerified) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.primary),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_outlined, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      l10n.underReviewBanner,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          _MetricCard(
            label: l10n.metricActiveListings,
            value: '$activeListings',
            icon: Icons.list_alt_outlined,
            onTap: () => context.go('/provider/listings'),
          ),
          const SizedBox(height: AppSpacing.md),
          _MetricCard(
            label: l10n.metricNewInquiries,
            value: '$newInquiries',
            icon: Icons.inbox_outlined,
            onTap: () => context.go('/provider/inquiries'),
          ),
          const SizedBox(height: AppSpacing.md),
          _MetricCard(
            label: l10n.metricPendingCommission,
            value: '$pendingCommission QAR',
            icon: Icons.payments_outlined,
            onTap: () => context.go('/provider/earnings'),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.divider),
          boxShadow: AppShadow.soft,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.surfaceAlt,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.textPrimary),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.caption),
                  Text(value, style: AppTypography.h2),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
