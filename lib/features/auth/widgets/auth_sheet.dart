import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/state/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_button.dart';

/// Just-in-time auth bottom sheet. Returns `true` if the user is authenticated
/// after the sheet closes (either was already signed in, or signed in here).
Future<bool> presentAuthSheet(BuildContext context, WidgetRef ref) async {
  final initial = ref.read(authProvider);
  if (initial.isAuthenticated) return true;
  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.sheet),
      ),
    ),
    builder: (context) => const _AuthSheet(),
  );
  return ok ?? ref.read(authProvider).isAuthenticated;
}

class _AuthSheet extends ConsumerStatefulWidget {
  const _AuthSheet();

  @override
  ConsumerState<_AuthSheet> createState() => _AuthSheetState();
}

class _AuthSheetState extends ConsumerState<_AuthSheet> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ok = await ref
        .read(authProvider.notifier)
        .login(_email.text, _password.text);
    if (!mounted) return;
    if (ok) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);
    final isBusy = auth.status == AuthStatus.authenticating;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.xxl,
        right: AppSpacing.xxl,
        top: AppSpacing.xxl,
        bottom: AppSpacing.xxl + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.authSheetTitle, style: AppTypography.h2),
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.authSheetHint, style: AppTypography.caption),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            enabled: !isBusy,
            decoration: InputDecoration(labelText: l10n.email),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _password,
            obscureText: true,
            enabled: !isBusy,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(labelText: l10n.password),
          ),
          if (auth.errorMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              auth.errorMessage!,
              style: AppTypography.caption.copyWith(color: AppColors.primary),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          isBusy
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2.5,
                  ),
                )
              : AppButton(
                  label: l10n.signIn,
                  onPressed: _submit,
                  expanded: true,
                ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: isBusy
                ? null
                : () {
                    Navigator.of(context).pop(false);
                    context.push('/register');
                  },
            child: Text(l10n.createAccount),
          ),
        ],
      ),
    );
  }
}
