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
import 'widgets/verification_banner.dart';

class MasterclassGateScreen extends ConsumerStatefulWidget {
  const MasterclassGateScreen({super.key});

  @override
  ConsumerState<MasterclassGateScreen> createState() =>
      _MasterclassGateScreenState();
}

class _MasterclassGateScreenState extends ConsumerState<MasterclassGateScreen> {
  bool _requesting = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authProvider).user;
    if (user == null) return const SizedBox.shrink();

    final verificationAsync = ref.watch(
      verificationForTypeProvider(UserRole.masterclass),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.becomeMasterclassProvider)),
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
                  ActiveInterface.masterclass;
              context.go(ActiveInterface.masterclass.basePath);
            });
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (verification.isUnderReview) {
            return _StatusBody(
              banner: VerificationBanner(
                icon: Icons.hourglass_top,
                message: l10n.masterclassAccountUnderReview,
              ),
              actions: [
                const CancelRequestButton(providerType: UserRole.masterclass),
              ],
            );
          }

          if (verification.isRejected) {
            return _StatusBody(
              banner: VerificationBanner(
                icon: Icons.error_outline,
                message: l10n.verificationRejected,
                reason: verification.comment,
              ),
              actions: [
                _requesting
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : AppButton(
                        label: l10n.requestAgain,
                        expanded: true,
                        onPressed: _request,
                      ),
                const SizedBox(height: AppSpacing.md),
                const CancelRequestButton(providerType: UserRole.masterclass),
              ],
            );
          }

          // none / cancelled — fresh request.
          return _RequestBody(
            l10n: l10n,
            requesting: _requesting,
            onRequest: _request,
          );
        },
      ),
    );
  }

  Future<void> _request() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _requesting = true);
    try {
      await ref
          .read(providerRepositoryProvider)
          .requestVerification(UserRole.masterclass);
      ref.invalidate(myVerificationsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.masterclassRequestSent)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _requesting = false);
    }
  }
}

/// Centred layout for a status banner followed by action buttons.
class _StatusBody extends StatelessWidget {
  const _StatusBody({required this.banner, required this.actions});

  final Widget banner;
  final List<Widget> actions;

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
            ...actions,
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: l10n.goBack,
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/'),
              expanded: true,
              variant: AppButtonVariant.outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestBody extends StatelessWidget {
  const _RequestBody({
    required this.l10n,
    required this.requesting,
    required this.onRequest,
  });

  final AppLocalizations l10n;
  final bool requesting;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.palette_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.becomeMasterclassProvider,
              style: AppTypography.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            requesting
                ? const CircularProgressIndicator(color: AppColors.primary)
                : AppButton(
                    label: l10n.requestMasterclassProvider,
                    onPressed: onRequest,
                    expanded: true,
                  ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: l10n.goBack,
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/'),
              expanded: true,
              variant: AppButtonVariant.outlined,
            ),
          ],
        ),
      ),
    );
  }
}
