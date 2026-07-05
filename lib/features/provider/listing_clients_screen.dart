import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/state/provider_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/util/relative_time.dart';
import '../../data/models/listing_enroll.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_refresh_indicator.dart';

/// Owner view of the families who requested one of their listings
/// (`/listing-clients/?listing=<id>`). Lets the owner accept / reject each
/// request.
class ListingClientsScreen extends ConsumerWidget {
  const ListingClientsScreen({
    super.key,
    required this.listingId,
    this.listingTitle,
  });

  final String listingId;
  final String? listingTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final clients = ref.watch(listingClientsProvider(listingId));

    return Scaffold(
      appBar: AppBar(title: Text(listingTitle ?? l10n.clients)),
      body: AppRefreshIndicator(
        onRefresh: () => ref.refresh(listingClientsProvider(listingId).future),
        child: clients.when(
          loading: () => const RefreshableMessage(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (e, _) => RefreshableMessage(child: Text(e.toString())),
          data: (items) => items.isEmpty
              ? RefreshableMessage(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 48,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(l10n.noClientsYet, style: AppTypography.h3),
                    ],
                  ),
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, i) =>
                      _ClientRow(client: items[i], listingId: listingId),
                ),
        ),
      ),
    );
  }
}

class _ClientRow extends ConsumerStatefulWidget {
  const _ClientRow({required this.client, required this.listingId});

  final ListingClient client;
  final String listingId;

  @override
  ConsumerState<_ClientRow> createState() => _ClientRowState();
}

class _ClientRowState extends ConsumerState<_ClientRow> {
  bool _busy = false;

  Future<void> _update(ListingEnrollmentStatus status) async {
    final l10n = AppLocalizations.of(context)!;
    final reject = status == ListingEnrollmentStatus.rejected;
    final comment = await _promptComment(reject: reject);
    // Null means the owner dismissed the dialog — abort without a status change.
    if (comment == null || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(listingEnrollmentRepositoryProvider)
          .updateClientStatus(
            widget.client.id,
            status,
            comment: comment.trim().isEmpty ? null : comment.trim(),
          );
      ref.invalidate(listingClientsProvider(widget.listingId));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.clientStatusUpdated),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e is StateError ? e.message : e.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Collects an owner note. Returns the entered text (may be empty when
  /// optional), or `null` if the dialog was dismissed. When [reject] is true a
  /// non-empty comment is enforced before the action button enables.
  Future<String?> _promptComment({required bool reject}) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: widget.client.comment);
    return showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final text = controller.text.trim();
          final canSubmit = reject ? text.isNotEmpty : true;
          return AlertDialog(
            title: Text(
              reject ? l10n.rejectEnrollmentTitle : l10n.acceptEnrollmentTitle,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reject ? l10n.commentRequiredHint : l10n.commentOptionalHint,
                  style: AppTypography.caption,
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: controller,
                  autofocus: true,
                  maxLines: 3,
                  onChanged: (_) => setDialogState(() {}),
                  decoration: InputDecoration(
                    hintText: l10n.commentHint,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: canSubmit
                    ? () => Navigator.of(ctx).pop(controller.text)
                    : null,
                child: Text(
                  reject ? l10n.decline : l10n.accept,
                  style: TextStyle(
                    color: canSubmit
                        ? AppColors.primary
                        : AppColors.textTertiary,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final client = widget.client;
    final user = client.user;

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
                child: Text(
                  user.fullName.isEmpty ? user.email : user.fullName,
                  style: AppTypography.h3.copyWith(fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _ClientStatusChip(status: client.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            formatRelative(client.createdAt, l10n),
            style: AppTypography.small,
          ),
          const SizedBox(height: AppSpacing.sm),
          _ContactLine(icon: Icons.email_outlined, value: user.email),
          if (user.phone != null && user.phone!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            _ContactLine(icon: Icons.phone_outlined, value: user.phone!),
          ],
          if (client.comment.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _CommentNote(comment: client.comment),
          ],
          const SizedBox(height: AppSpacing.md),
          if (_busy)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.sm),
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2.5,
                ),
              ),
            )
          else
            Row(
              children: [
                if (client.status != ListingEnrollmentStatus.rejected)
                  Expanded(
                    child: AppButton(
                      label: l10n.decline,
                      variant: AppButtonVariant.outlined,
                      onPressed: () =>
                          _update(ListingEnrollmentStatus.rejected),
                    ),
                  ),
                if (client.status != ListingEnrollmentStatus.rejected &&
                    client.status != ListingEnrollmentStatus.accepted)
                  const SizedBox(width: AppSpacing.md),
                if (client.status != ListingEnrollmentStatus.accepted)
                  Expanded(
                    child: AppButton(
                      label: l10n.accept,
                      onPressed: () =>
                          _update(ListingEnrollmentStatus.accepted),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ContactLine extends StatelessWidget {
  const _ContactLine({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            value,
            style: AppTypography.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _CommentNote extends StatelessWidget {
  const _CommentNote({required this.comment});

  final String comment;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Expanded(child: Text(comment, style: AppTypography.caption)),
        ],
      ),
    );
  }
}

class _ClientStatusChip extends StatelessWidget {
  const _ClientStatusChip({required this.status});

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
