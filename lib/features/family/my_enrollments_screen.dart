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
import '../../data/models/listing_enroll.dart';
import '../../shared/widgets/app_refresh_indicator.dart';

class MyRequestsScreen extends ConsumerWidget {
  const MyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authProvider).user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.myRequests)),
        body: Center(child: Text(l10n.signIn)),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.myRequests),
          bottom: TabBar(
            labelColor: AppColors.primary,
            indicatorColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: l10n.myRequestsTabListings),
              Tab(text: l10n.myRequestsTabTutors),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const _ListingsTab(),
            _TutorsTab(familyId: user.id),
          ],
        ),
      ),
    );
  }
}

// ── Listings tab (ListingEnrollment / ListingClient) ────────────────────────────

class _ListingsTab extends ConsumerWidget {
  const _ListingsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final requests = ref.watch(myListingEnrollmentsProvider);

    return AppRefreshIndicator(
      onRefresh: () => ref.refresh(myListingEnrollmentsProvider.future),
      child: requests.when(
        loading: () => const RefreshableMessage(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => RefreshableMessage(child: Text(error.toString())),
        data: (items) => items.isEmpty
            ? RefreshableMessage(
                child: Text(l10n.noEnrollmentsYet, style: AppTypography.h3),
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: items.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, i) =>
                    _ListingEnrollmentRow(request: items[i]),
              ),
      ),
    );
  }
}

class _ListingEnrollmentRow extends ConsumerWidget {
  const _ListingEnrollmentRow({required this.request});

  final ListingEnrollment request;

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.cancelListingEnrollmentTitle),
        content: Text(l10n.cancelListingEnrollmentMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.keepEnrollment),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l10n.cancelRequestConfirm,
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref
          .read(listingEnrollmentRepositoryProvider)
          .cancelEnrollment(request.id);
      ref.invalidate(myListingEnrollmentsProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.enrollmentCancelled),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e is StateError ? e.message : e.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final listing = request.listing;

    return GestureDetector(
      onTap: () => context.push('/listing/${listing.id}'),
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
                _StatusChip(status: request.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              formatRelative(request.createdAt, l10n),
              style: AppTypography.small,
            ),
            if (listing.neighborhood.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(listing.neighborhood, style: AppTypography.caption),
            ],
            if (request.comment.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        request.comment,
                        style: AppTypography.caption,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _cancel(context, ref),
                icon: const Icon(Icons.close, size: 16),
                label: Text(l10n.cancelEnrollment),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final ListingEnrollmentStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (label, color) = switch (status) {
      ListingEnrollmentStatus.pending => (
        l10n.requestStatusPending,
        AppColors.primary,
      ),
      ListingEnrollmentStatus.accepted => (
        l10n.requestStatusAccepted,
        AppColors.success,
      ),
      ListingEnrollmentStatus.rejected => (
        l10n.requestStatusDeclined,
        AppColors.textTertiary,
      ),
    };
    return _Chip(label: label, color: color);
  }
}

// ── Tutors tab (Inquiry) ─────────────────────────────────────────────────────

class _TutorsTab extends ConsumerWidget {
  const _TutorsTab({required this.familyId});

  final String familyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final inquiries = ref.watch(myInquiriesProvider(familyId));

    return AppRefreshIndicator(
      onRefresh: () => ref.refresh(myInquiriesProvider(familyId).future),
      child: inquiries.when(
        loading: () => const RefreshableMessage(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => RefreshableMessage(child: Text(error.toString())),
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
                itemBuilder: (context, i) => _InquiryRow(inquiry: items[i]),
              ),
      ),
    );
  }
}

class _InquiryRow extends StatelessWidget {
  const _InquiryRow({required this.inquiry});

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
                _InquiryStatusChip(status: inquiry.status),
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

class _InquiryStatusChip extends StatelessWidget {
  const _InquiryStatusChip({required this.status});

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
    return _Chip(label: label, color: color);
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
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
