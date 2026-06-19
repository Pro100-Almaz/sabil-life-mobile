import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/state/auth_provider.dart';
import '../../core/state/provider_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/util/relative_time.dart';
import '../../data/models/inquiry.dart';
import '../../shared/widgets/app_button.dart';

class InquiriesScreen extends ConsumerStatefulWidget {
  const InquiriesScreen({super.key});

  @override
  ConsumerState<InquiriesScreen> createState() => _InquiriesScreenState();
}

class _InquiriesScreenState extends ConsumerState<InquiriesScreen> {
  InquiryStatus? _filter; // null = show all

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authProvider).user;
    if (user == null) return const SizedBox.shrink();
    final inquiriesAsync = ref.watch(incomingInquiriesProvider(user.id));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.inquiries)),
      body: Column(
        children: [
          _StatusFilterBar(
            selected: _filter,
            onSelected: (s) => setState(() => _filter = s),
          ),
          Expanded(
            child: inquiriesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (all) {
                final items = _filter == null
                    ? all
                    : all.where((i) => i.status == _filter).toList();
                if (items.isEmpty) {
                  return Center(
                    child: Text(l10n.noInquiriesYet, style: AppTypography.h3),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: items.length,
                  separatorBuilder: (context, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (_, i) =>
                      _InquiryCard(inquiry: items[i], providerId: user.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusFilterBar extends StatelessWidget {
  const _StatusFilterBar({required this.selected, required this.onSelected});

  final InquiryStatus? selected;
  final ValueChanged<InquiryStatus?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final options = <(InquiryStatus?, String)>[
      (null, l10n.filterAll),
      (InquiryStatus.new_, l10n.requestStatusPending),
      (InquiryStatus.contacted, l10n.statusContacted),
      (InquiryStatus.accepted, l10n.requestStatusAccepted),
      (InquiryStatus.declined, l10n.requestStatusDeclined),
      (InquiryStatus.completed, l10n.statusCompleted),
    ];
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        children: [
          for (final (status, label) in options) ...[
            _FilterChip(
              label: label,
              selected: selected == status,
              onTap: () => onSelected(status),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.small.copyWith(
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
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

  Future<void> _runAction(Future<Inquiry> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(incomingInquiriesProvider(widget.providerId));
    } on StateError catch (e) {
      if (!mounted) return;
      final msg = e.message;
      // 409 prefix added by HttpProviderRepository
      final display = msg.startsWith('409:') ? msg.substring(4) : msg;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(display)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final inq = widget.inquiry;
    final repo = ref.read(providerRepositoryProvider);

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
                      inq.familyName ?? '—',
                      style: AppTypography.h3.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(inq.listingId, style: AppTypography.caption),
                  ],
                ),
              ),
              _StatusChip(status: inq.status),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(formatRelative(inq.createdAt, l10n), style: AppTypography.small),
          const SizedBox(height: AppSpacing.md),
          Text(inq.message, style: AppTypography.body),
          const SizedBox(height: AppSpacing.md),
          // Contact block
          if (inq.contactRevealed &&
              (inq.familyEmail != null || inq.familyPhone != null)) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.success,
                        size: 16,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        l10n.providerContactRevealed,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  if (inq.familyEmail != null) ...[
                    const SizedBox(height: 4),
                    Text(inq.familyEmail!, style: AppTypography.body),
                  ],
                  if (inq.familyPhone != null) ...[
                    const SizedBox(height: 2),
                    Text(inq.familyPhone!, style: AppTypography.body),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ] else if (!inq.contactRevealed) ...[
            Text(
              l10n.providerContactNotRevealed,
              style: AppTypography.small.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          // Action buttons
          if (_busy)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          else
            _ActionButtons(
              status: inq.status,
              l10n: l10n,
              onContacted: () => _runAction(() => repo.markContacted(inq.id)),
              onAccept: () => _runAction(() => repo.acceptInquiry(inq.id)),
              onDecline: () => _runAction(() => repo.declineInquiry(inq.id)),
              onComplete: () => _runAction(() => repo.completeInquiry(inq.id)),
            ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.status,
    required this.l10n,
    required this.onContacted,
    required this.onAccept,
    required this.onDecline,
    required this.onComplete,
  });

  final InquiryStatus status;
  final AppLocalizations l10n;
  final VoidCallback onContacted;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      InquiryStatus.new_ || InquiryStatus.pending => Row(
        children: [
          Expanded(
            child: AppButton(
              label: l10n.decline,
              variant: AppButtonVariant.outlined,
              onPressed: onDecline,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppButton(
              label: l10n.providerMarkContacted,
              variant: AppButtonVariant.outlined,
              onPressed: onContacted,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppButton(label: l10n.accept, onPressed: onAccept),
          ),
        ],
      ),
      InquiryStatus.contacted => Row(
        children: [
          Expanded(
            child: AppButton(
              label: l10n.decline,
              variant: AppButtonVariant.outlined,
              onPressed: onDecline,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: AppButton(label: l10n.accept, onPressed: onAccept),
          ),
        ],
      ),
      InquiryStatus.accepted => AppButton(
        label: l10n.providerComplete,
        onPressed: onComplete,
      ),
      InquiryStatus.declined ||
      InquiryStatus.completed => const SizedBox.shrink(),
    };
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
        l10n.statusContacted,
        AppColors.textSecondary,
      ),
      InquiryStatus.accepted => (l10n.requestStatusAccepted, AppColors.success),
      InquiryStatus.declined => (
        l10n.requestStatusDeclined,
        AppColors.textTertiary,
      ),
      InquiryStatus.completed => (l10n.statusCompleted, AppColors.success),
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
