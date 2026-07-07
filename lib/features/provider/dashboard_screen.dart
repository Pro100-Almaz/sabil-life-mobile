import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/state/auth_provider.dart';
import '../../core/state/notifications_provider.dart';
import '../../core/state/provider_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/inquiry.dart';
import '../../data/models/listing.dart';
import '../../data/models/subscription.dart';
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
    final subscribersAsync = ref.watch(
      incomingSubscriptionsProvider(const SubscriptionsFilter()),
    );

    final totalListings = listingsAsync.maybeWhen(
      data: (items) => items.length,
      orElse: () => 0,
    );
    final activeListings = listingsAsync.maybeWhen(
      data: (items) =>
          items.where((l) => l.status == ListingStatus.active).length,
      orElse: () => 0,
    );
    final newInquiries = inquiriesAsync.maybeWhen(
      data: (items) => items
          .where(
            (i) =>
                i.status == InquiryStatus.new_ ||
                i.status == InquiryStatus.contacted,
          )
          .length,
      orElse: () => 0,
    );
    final subscriberCount = subscribersAsync.maybeWhen(
      data: (items) =>
          items.where((s) => s.status == SubscriptionStatus.confirmed).length,
      orElse: () => 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.welcomeBack(user.fullName)),
        toolbarHeight: 72,
        actions: const [_NotificationBell()],
      ),
      body: AppRefreshIndicator(
        onRefresh: () async {
          ref.invalidate(providerProfileProvider);
          await Future.wait([
            ref.refresh(myListingsProvider(user.id).future),
            ref.refresh(incomingInquiriesProvider(user.id).future),
            ref.refresh(
              incomingSubscriptionsProvider(const SubscriptionsFilter()).future,
            ),
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
            // Listings live only on the masterclass interface.
            if (interface == ActiveInterface.masterclass) ...[
              _MetricCard(
                label: l10n.metricActiveListings,
                value: '$activeListings / $totalListings',
                icon: Icons.list_alt_outlined,
                onTap: () => context.go('${interface.basePath}/listings'),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            // Inquiries live only on the tutor interface.
            if (interface == ActiveInterface.tutor) ...[
              _MetricCard(
                label: l10n.metricNewInquiries,
                value: '$newInquiries',
                icon: Icons.inbox_outlined,
                onTap: () => context.go('${interface.basePath}/inquiries'),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            _MetricCard(
              label: l10n.providerSubscribers,
              value: '$subscriberCount',
              icon: Icons.people_outline,
              onTap: () => context.go(
                interface == ActiveInterface.tutor
                    ? '${interface.basePath}/inquiries'
                    : '${interface.basePath}/listings',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Subscribers mini-roster
            subscribersAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => const SizedBox.shrink(),
              data: (subs) {
                final confirmed = subs
                    .where((s) => s.status == SubscriptionStatus.confirmed)
                    .toList();
                if (confirmed.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.providerSubscribers, style: AppTypography.h3),
                    const SizedBox(height: AppSpacing.sm),
                    for (final sub in confirmed.take(3)) ...[
                      _SubscriberRow(subscription: sub),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                );
              },
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

class _SubscriberRow extends StatelessWidget {
  const _SubscriberRow({required this.subscription});

  final Subscription subscription;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final dateLabel = DateFormat(
      'd MMM yyyy',
      locale,
    ).format(subscription.createdAt);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subscription.familyName ?? '—', style: AppTypography.body),
                if (subscription.listingTitle != null)
                  Text(subscription.listingTitle!, style: AppTypography.small),
              ],
            ),
          ),
          Text(dateLabel, style: AppTypography.small),
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
