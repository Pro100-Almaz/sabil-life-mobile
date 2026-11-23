import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/state/provider_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/ownership_request.dart';
import '../../shared/widgets/app_refresh_indicator.dart';

class OwnershipRequestsScreen extends ConsumerWidget {
  const OwnershipRequestsScreen({super.key});

  Future<void> _cancel(BuildContext context, WidgetRef ref, int id) async {
    try {
      await ref.read(providerRepositoryProvider).cancelOwnershipRequest(id);
      ref.invalidate(myOwnershipRequestsProvider);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is StateError
                ? error.message
                : AppLocalizations.of(context)!.genericLoadError,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final requests = ref.watch(myOwnershipRequestsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.ownershipRequests)),
      body: AppRefreshIndicator(
        onRefresh: () => ref.refresh(myOwnershipRequestsProvider.future),
        child: requests.when(
          loading: () => const RefreshableMessage(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (error, _) =>
              RefreshableMessage(child: Text(error.toString())),
          data: (items) => items.isEmpty
              ? RefreshableMessage(child: Text(l10n.noOwnershipRequests))
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: items.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) => _RequestCard(
                    request: items[index],
                    onCancel: () => _cancel(context, ref, items[index].id),
                  ),
                ),
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request, required this.onCancel});

  final OwnershipRequest request;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = switch (request.status) {
      OwnershipRequestStatus.pending => l10n.ownershipStatusPending,
      OwnershipRequestStatus.approved => l10n.ownershipStatusApproved,
      OwnershipRequestStatus.rejected => l10n.ownershipStatusRejected,
      OwnershipRequestStatus.cancelled => l10n.ownershipStatusCancelled,
    };
    final color = switch (request.status) {
      OwnershipRequestStatus.pending => AppColors.primary,
      OwnershipRequestStatus.approved => AppColors.success,
      OwnershipRequestStatus.rejected => AppColors.primaryPressed,
      OwnershipRequestStatus.cancelled => AppColors.textTertiary,
    };
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
                child: Text(request.listingTitle, style: AppTypography.h3),
              ),
              Text(label, style: AppTypography.label.copyWith(color: color)),
            ],
          ),
          if (request.message.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(request.message, style: AppTypography.caption),
          ],
          if (request.status == OwnershipRequestStatus.rejected &&
              request.comment.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.ownershipReviewNote(request.comment),
              style: AppTypography.caption,
            ),
          ],
          if (request.canCancel) ...[
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onCancel,
                child: Text(l10n.cancelOwnershipRequest),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
