import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/state/auth_provider.dart';
import '../../core/state/provider_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/auth_user.dart';
import '../../shared/widgets/app_button.dart';
import 'widgets/tutor_profile_form.dart';
import 'widgets/verification_banner.dart';

class TutorGateScreen extends ConsumerWidget {
  const TutorGateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authProvider).user;
    if (user == null) return const SizedBox.shrink();

    final verificationAsync = ref.watch(
      verificationForTypeProvider(UserRole.tutor),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.becomeTutor)),
      body: verificationAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.genericLoadError, style: AppTypography.body),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: l10n.goBack,
                  onPressed: () =>
                      context.canPop() ? context.pop() : context.go('/'),
                ),
              ],
            ),
          ),
        ),
        data: (verification) {
          if (verification.isApproved) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(activeInterfaceProvider.notifier).state =
                  ActiveInterface.tutor;
              context.go(ActiveInterface.tutor.basePath);
            });
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (verification.isUnderReview) {
            return _StatusBody(
              banner: VerificationBanner(
                icon: Icons.hourglass_top,
                message: l10n.tutorAccountUnderReview,
              ),
              editLabel: l10n.editProfile,
            );
          }

          if (verification.isRejected) {
            return _StatusBody(
              banner: VerificationBanner(
                icon: Icons.error_outline,
                message: l10n.verificationRejected,
                reason: verification.comment,
              ),
              editLabel: l10n.editAndResubmit,
            );
          }

          // none / cancelled — fill the profile to request verification.
          return TutorProfileForm(
            userId: user.id,
            headerMessage: l10n.fillTutorProfile,
          );
        },
      ),
    );
  }
}

/// Banner + "edit profile" + "cancel request" + "go back" layout, shared by the
/// under-review and rejected states.
class _StatusBody extends StatelessWidget {
  const _StatusBody({required this.banner, required this.editLabel});

  final Widget banner;
  final String editLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            banner,
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: editLabel,
              onPressed: () => context.push('/tutor-profile-edit'),
              expanded: true,
            ),
            const SizedBox(height: AppSpacing.md),
            const CancelRequestButton(providerType: UserRole.tutor),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: l10n.goBack,
              variant: AppButtonVariant.outlined,
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/'),
              expanded: true,
            ),
          ],
        ),
      ),
    );
  }
}
