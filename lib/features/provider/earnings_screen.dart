import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/state/auth_provider.dart';
import '../../core/state/provider_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/commission.dart';

class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authProvider).user;
    if (user == null) return const SizedBox.shrink();
    final earningsAsync = ref.watch(earningsProvider(user.id));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.earnings)),
      body: earningsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (summary) => ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Row(
              children: [
                Expanded(
                  child: _Metric(
                    label: l10n.acceptedStudents,
                    value: '${summary.acceptedStudents}',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _Metric(
                    label: l10n.pendingCommission,
                    value: '${summary.pendingQar} QAR',
                    accent: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _Metric(
                    label: l10n.paidCommission,
                    value: '${summary.paidQar} QAR',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            if (summary.commissions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
                child: Center(
                  child: Text(
                    l10n.commissionListEmpty,
                    style: AppTypography.caption,
                  ),
                ),
              )
            else
              for (final c in summary.commissions) ...[
                _CommissionRow(commission: c),
                const SizedBox(height: AppSpacing.sm),
              ],
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    this.accent = false,
  });

  final String label;
  final String value;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: accent ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.small.copyWith(
              color: accent ? Colors.white : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.h3.copyWith(
              color: accent ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommissionRow extends StatelessWidget {
  const _CommissionRow({required this.commission});

  final Commission commission;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final dateLabel = DateFormat(
      'd MMM yyyy',
      locale,
    ).format(commission.createdAt);
    final statusLabel = commission.status == CommissionStatus.paid
        ? l10n.paidCommission
        : l10n.pendingCommission;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${commission.amountQar} QAR',
                style: AppTypography.h3.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 2),
              Text(dateLabel, style: AppTypography.small),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.chip),
              border: Border.all(
                color: commission.status == CommissionStatus.paid
                    ? AppColors.success
                    : AppColors.primary,
              ),
            ),
            child: Text(
              statusLabel,
              style: AppTypography.small.copyWith(
                color: commission.status == CommissionStatus.paid
                    ? AppColors.success
                    : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
