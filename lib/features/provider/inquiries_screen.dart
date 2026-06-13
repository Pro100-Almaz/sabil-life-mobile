import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/state/auth_provider.dart';
import '../../core/state/provider_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/util/relative_time.dart';
import '../../data/mock/mock_listings.dart';
import '../../data/models/commission.dart';
import '../../data/models/inquiry.dart';
import '../../shared/widgets/app_button.dart';

class InquiriesScreen extends ConsumerWidget {
  const InquiriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authProvider).user;
    if (user == null) return const SizedBox.shrink();
    final inquiriesAsync = ref.watch(incomingInquiriesProvider(user.id));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.inquiries)),
      body: inquiriesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (items) => items.isEmpty
            ? Center(child: Text(l10n.noInquiriesYet, style: AppTypography.h3))
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: items.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, i) =>
                    _InquiryCard(inquiry: items[i], providerId: user.id),
              ),
      ),
    );
  }
}

class _InquiryCard extends ConsumerStatefulWidget {
  const _InquiryCard({required this.inquiry, required this.providerId});

  final Inquiry inquiry;
  final String providerId;

  @override
  ConsumerState<_InquiryCard> createState() => _InquiryCardState();
}

class _InquiryCardState extends ConsumerState<_InquiryCard> {
  bool _busy = false;

  Future<void> _accept() async {
    setState(() => _busy = true);
    try {
      final commission = await ref
          .read(providerRepositoryProvider)
          .acceptInquiry(widget.inquiry.id);
      ref.invalidate(incomingInquiriesProvider(widget.providerId));
      ref.invalidate(earningsProvider(widget.providerId));
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.commissionApplies(commission.amountQar))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _decline() async {
    setState(() => _busy = true);
    try {
      await ref
          .read(providerRepositoryProvider)
          .declineInquiry(widget.inquiry.id);
      ref.invalidate(incomingInquiriesProvider(widget.providerId));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final listing = listingById(widget.inquiry.listingId);
    final isPending = widget.inquiry.status == InquiryStatus.pending;
    final isAccepted = widget.inquiry.status == InquiryStatus.accepted;

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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.inquiry.familyName,
                      style: AppTypography.h3.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      listing?.title ?? widget.inquiry.listingId,
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              _StatusChip(status: widget.inquiry.status),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            formatRelative(widget.inquiry.createdAt, l10n),
            style: AppTypography.small,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(widget.inquiry.message, style: AppTypography.body),
          if (isAccepted) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      l10n.contactRevealed(widget.inquiry.familyEmail),
                      style: AppTypography.caption,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (isPending) ...[
            const SizedBox(height: AppSpacing.md),
            if (_busy)
              const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: l10n.decline,
                      variant: AppButtonVariant.outlined,
                      onPressed: _decline,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      label: '${l10n.accept} · $kInquiryCommissionQar QAR',
                      onPressed: _accept,
                    ),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final InquiryStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (label, color) = switch (status) {
      InquiryStatus.pending => (l10n.requestStatusPending, AppColors.primary),
      InquiryStatus.accepted => (l10n.requestStatusAccepted, AppColors.success),
      InquiryStatus.declined => (
        l10n.requestStatusDeclined,
        AppColors.textTertiary,
      ),
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
