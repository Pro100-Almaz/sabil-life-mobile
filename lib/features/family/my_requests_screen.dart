import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/state/auth_provider.dart';
import '../../core/state/provider_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/util/relative_time.dart';
import '../../data/models/inquiry.dart';
import '../../shared/widgets/app_refresh_indicator.dart';

class MyRequestsScreen extends ConsumerWidget {
  const MyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);
    final user = auth.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.myRequests)),
        body: Center(child: Text(l10n.signIn)),
      );
    }

    final inquiries = ref.watch(myInquiriesProvider(user.id));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myRequests)),
      body: AppRefreshIndicator(
        onRefresh: () => ref.refresh(myInquiriesProvider(user.id).future),
        child: inquiries.when(
          loading: () => const RefreshableMessage(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (error, _) =>
              RefreshableMessage(child: Text(error.toString())),
          data: (items) => items.isEmpty
              ? RefreshableMessage(
                  child: Text(l10n.noRequestsYet, style: AppTypography.h3),
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, i) => _RequestRow(inquiry: items[i]),
                ),
        ),
      ),
    );
  }
}

class _RequestRow extends StatelessWidget {
  const _RequestRow({required this.inquiry});

  final Inquiry inquiry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () => context.push('/listing/${inquiry.listingId}'),
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
                    inquiry.listingId,
                    style: AppTypography.h3.copyWith(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _StatusChip(status: inquiry.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              formatRelative(inquiry.createdAt, l10n),
              style: AppTypography.small,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              inquiry.message,
              style: AppTypography.caption,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
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
      InquiryStatus.new_ ||
      InquiryStatus.pending => (l10n.requestStatusPending, AppColors.primary),
      InquiryStatus.contacted => (
        l10n.requestStatusPending,
        AppColors.textSecondary,
      ),
      InquiryStatus.accepted => (l10n.requestStatusAccepted, AppColors.success),
      InquiryStatus.declined => (
        l10n.requestStatusDeclined,
        AppColors.textTertiary,
      ),
      InquiryStatus.completed => (
        l10n.requestStatusAccepted,
        AppColors.success,
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
