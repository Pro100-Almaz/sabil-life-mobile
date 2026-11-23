import '../../core/state/provider_subscriptions_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/state/auth_provider.dart';
import '../../core/state/notifications_provider.dart';
import '../../core/state/provider_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/inquiry.dart';
import '../../data/models/listing.dart';
// import '../../data/models/subscription.dart';
import '../../shared/widgets/app_refresh_indicator.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key, required this.interface});

  final ActiveInterface interface;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);
    final user = auth.user;
    if (user == null) return const SizedBox.shrink();

    final profileAsync = ref.watch(providerProfileProvider);
    final listingsAsync = ref.watch(myListingsProvider(user.id));
    final inquiriesAsync = ref.watch(incomingInquiriesProvider(user.id));
    final subscriberCount = ref.watch(mySubscriberCountProvider);

    final regularListings = listingsAsync.maybeWhen(
      data: (items) =>
          items.where((l) => l.category != CategoryType.masterclasses).length,
      orElse: () => 0,
    );
    final masterclasses = listingsAsync.maybeWhen(
      data: (items) =>
          items.where((l) => l.category == CategoryType.masterclasses).length,
      orElse: () => 0,
    );
    final newInquiries = inquiriesAsync.maybeWhen(
      data: (items) => items
          .where(
            (i) =>
                i.status == InquiryStatus.pending ||
                i.status == InquiryStatus.accepted,
          )
          .length,
      orElse: () => 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          interface == ActiveInterface.masterclass
              ? l10n.providerDashboard
              : l10n.welcomeBack(user.fullName),
        ),
        toolbarHeight: 72,
        actions: const [_NotificationBell()],
      ),
      body: AppRefreshIndicator(
        onRefresh: () async {
          ref.invalidate(providerProfileProvider);
          await Future.wait([
            ref.refresh(myListingsProvider(user.id).future),
            ref.refresh(incomingInquiriesProvider(user.id).future),
            ref.refresh(mySubscriberCountProvider.future),
          ]);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            if (profileAsync.maybeWhen(
              data: (p) => !p.isVerified,
              orElse: () => false,
            )) ...[
              _UnverifiedBanner(message: l10n.providerUnverifiedBanner),
              const SizedBox(height: AppSpacing.lg),
            ],
            // The masterclass interface is the general provider workspace.
            if (interface == ActiveInterface.masterclass) ...[
              _MetricCard(
                label: l10n.regularListings,
                value: '$regularListings',
                icon: Icons.list_alt_outlined,
                onTap: () => context.go('${interface.basePath}/listings'),
              ),
              const SizedBox(height: AppSpacing.md),
              _MetricCard(
                label: l10n.catMasterclasses,
                value: '$masterclasses',
                icon: Icons.event_outlined,
                onTap: () => context.go('${interface.basePath}/masterclasses'),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            if (interface.isProvider) ...[
              _MetricCard(
                label: l10n.metricNewInquiries,
                value: '$newInquiries',
                icon: Icons.inbox_outlined,
                onTap: () => context.go('${interface.basePath}/inquiries'),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            subscriberCount.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Column(
                children: [
                  Text(l10n.genericLoadError),
                  TextButton(
                    onPressed: () => ref.invalidate(mySubscriberCountProvider),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
              data: (count) => _MetricCard(
                label: l10n.providerSubscribers,
                value: '$count',
                icon: Icons.people_outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnverifiedBanner extends StatelessWidget {
  const _UnverifiedBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              message,
              style: AppTypography.caption.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
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
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

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
            if (onTap != null)
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

/// App-bar bell that shows the unread notification count and opens the feed.
class _NotificationBell extends ConsumerWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Unread count is best-effort chrome — any error just hides the badge.
    final unread = ref
        .watch(unreadCountProvider)
        .maybeWhen(data: (n) => n, orElse: () => 0);
    return Badge.count(
      count: unread,
      isLabelVisible: unread > 0,
      child: IconButton(
        icon: const Icon(Icons.notifications_none),
        onPressed: () => context.push('/notifications'),
      ),
    );
  }
}
