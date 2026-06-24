import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/state/auth_provider.dart';
import '../../../core/state/provider_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/auth_user.dart';
import '../../../shared/widgets/app_button.dart';

/// A soft coral panel summarising a verification's current state. When
/// [reason] is non-empty it is shown as a labelled rejection comment.
class VerificationBanner extends StatelessWidget {
  const VerificationBanner({
    super.key,
    required this.icon,
    required this.message,
    this.reason = '',
  });

  final IconData icon;
  final String message;
  final String reason;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          if (reason.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.verificationRejectedReason,
              style: AppTypography.caption.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(reason, style: AppTypography.body),
          ],
        ],
      ),
    );
  }
}

/// Outlined button that cancels the verification request for [providerType]
/// after a confirmation dialog, then refreshes the verification state.
class CancelRequestButton extends ConsumerStatefulWidget {
  const CancelRequestButton({super.key, required this.providerType});

  final UserRole providerType;

  @override
  ConsumerState<CancelRequestButton> createState() =>
      _CancelRequestButtonState();
}

class _CancelRequestButtonState extends ConsumerState<CancelRequestButton> {
  bool _cancelling = false;

  Future<void> _cancel() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cancelRequestTitle),
        content: Text(l10n.cancelRequestMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.keepRequest),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.cancelRequestConfirm,
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _cancelling = true);
    try {
      await ref
          .read(providerRepositoryProvider)
          .cancelVerification(widget.providerType);
      ref.invalidate(myVerificationsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.requestCancelled)));
      // After cancelling, return to the provider settings tab.
      final basePath = widget.providerType == UserRole.masterclass
          ? ActiveInterface.masterclass.basePath
          : ActiveInterface.tutor.basePath;
      context.go('$basePath/settings');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_cancelling) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    return AppButton(
      label: l10n.cancelRequest,
      variant: AppButtonVariant.outlined,
      expanded: true,
      onPressed: _cancel,
    );
  }
}
