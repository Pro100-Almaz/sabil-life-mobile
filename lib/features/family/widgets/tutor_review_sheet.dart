import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/state/provider_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/repositories/review_repository.dart';
import '../../../shared/widgets/app_button.dart';

/// Bottom sheet for reviewing a tutor. Mirrors the listing review sheet
/// (`showReviewSheet`) but posts against the tutor surface and is gated by the
/// engagement state of the family's inquiry.
///
/// When [existingReviewId] is non-null the sheet opens in edit mode: the comment
/// is pre-filled from [initialText], the primary button updates, and a delete
/// affordance appears. [initialRating] pre-selects the star the family tapped
/// on the inquiry card. [familyId] keys the inquiry list to refresh on save.
void showTutorReviewSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String tutorId,
  required String tutorName,
  required String familyId,
  int initialRating = 5,
  String? existingReviewId,
  String initialText = '',
}) {
  final l10n = AppLocalizations.of(context)!;
  final isEditing = existingReviewId != null;
  var rating = initialRating.clamp(1, 5);
  final textController = TextEditingController(text: initialText);
  var submitting = false;

  void invalidate() {
    // The family's review rides on the inquiry response, so refresh the list.
    ref.invalidate(myInquiriesProvider(familyId));
    ref.invalidate(tutorReviewsProvider(tutorId));
  }

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => StatefulBuilder(
      builder: (ctx, setModalState) {
        Future<void> submit() async {
          if (textController.text.trim().isEmpty) return;
          setModalState(() => submitting = true);
          try {
            if (existingReviewId != null) {
              await ref
                  .read(tutorReviewRepositoryProvider)
                  .update(
                    reviewId: existingReviewId,
                    rating: rating,
                    text: textController.text.trim(),
                  );
            } else {
              await ref
                  .read(tutorReviewRepositoryProvider)
                  .create(
                    tutorId: tutorId,
                    rating: rating,
                    text: textController.text.trim(),
                  );
            }
            invalidate();
            if (!ctx.mounted) return;
            Navigator.of(ctx).pop();
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(
                  isEditing ? l10n.reviewUpdated : l10n.reviewSubmitted,
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          } on ReviewException catch (e) {
            if (!ctx.mounted) return;
            Navigator.of(ctx).pop();
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(e.message),
                behavior: SnackBarBehavior.floating,
              ),
            );
          } catch (e) {
            if (!ctx.mounted) return;
            Navigator.of(ctx).pop();
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(e.toString()),
                behavior: SnackBarBehavior.floating,
              ),
            );
          } finally {
            if (ctx.mounted) setModalState(() => submitting = false);
          }
        }

        Future<void> deleteReview() async {
          final confirmed = await showDialog<bool>(
            context: ctx,
            builder: (dialogCtx) => AlertDialog(
              title: Text(l10n.deleteReview),
              content: Text(l10n.deleteReviewConfirm),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(false),
                  child: Text(l10n.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(true),
                  child: Text(
                    l10n.deleteReview,
                    style: const TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          );
          if (confirmed != true) return;
          setModalState(() => submitting = true);
          try {
            await ref
                .read(tutorReviewRepositoryProvider)
                .delete(existingReviewId!);
            invalidate();
            if (!ctx.mounted) return;
            Navigator.of(ctx).pop();
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(l10n.reviewDeleted),
                behavior: SnackBarBehavior.floating,
              ),
            );
          } catch (e) {
            if (!ctx.mounted) return;
            Navigator.of(ctx).pop();
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(e.toString()),
                behavior: SnackBarBehavior.floating,
              ),
            );
          } finally {
            if (ctx.mounted) setModalState(() => submitting = false);
          }
        }

        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.xxl,
            right: AppSpacing.xxl,
            top: AppSpacing.xl,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? l10n.editReview : l10n.writeReview,
                style: AppTypography.h2,
              ),
              if (tutorName.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(tutorName, style: AppTypography.caption),
              ],
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final star = i + 1;
                  return GestureDetector(
                    onTap: () => setModalState(() => rating = star),
                    child: Icon(
                      star <= rating ? Icons.star : Icons.star_border,
                      color: AppColors.star,
                      size: 32,
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: textController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: l10n.shareExperience,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: submitting
                    ? (isEditing ? l10n.updating : l10n.submitting)
                    : (isEditing ? l10n.update : l10n.submit),
                expanded: true,
                onPressed: submitting ? () {} : submit,
              ),
              if (isEditing) ...[
                const SizedBox(height: AppSpacing.sm),
                TextButton.icon(
                  onPressed: submitting ? null : deleteReview,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: Text(l10n.deleteReview),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    ),
  );
}
