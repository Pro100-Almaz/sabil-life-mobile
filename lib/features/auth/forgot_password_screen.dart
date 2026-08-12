import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/state/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/app_button.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _password2 = TextEditingController();

  final _requestFormKey = GlobalKey<FormState>();
  final _confirmFormKey = GlobalKey<FormState>();

  bool _codeSent = false;
  bool _passwordHidden = true;
  bool _password2Hidden = true;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _password.dispose();
    _password2.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    if (!_requestFormKey.currentState!.validate()) return;

    final ok = await ref
        .read(authProvider.notifier)
        .requestPasswordReset(email: _email.text);

    if (!mounted) return;

    if (ok) {
      setState(() => _codeSent = true);
    }
  }

  Future<void> _confirmReset() async {
    if (!_confirmFormKey.currentState!.validate()) return;

    final ok = await ref
        .read(authProvider.notifier)
        .confirmPasswordReset(
          email: _email.text,
          code: _code.text,
          password: _password.text,
          password2: _password2.text,
        );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.passwordResetSuccessful),
        ),
      );
      context.go('/login');
    }
  }

  Future<void> _resendCode() async {
    final ok = await ref
        .read(authProvider.notifier)
        .requestPasswordReset(email: _email.text);

    if (!mounted || !ok) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.codeResent)),
    );
  }

  void _editEmail() {
    _code.clear();
    _password.clear();
    _password2.clear();
    setState(() => _codeSent = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);
    final isBusy = auth.status == AuthStatus.authenticating;

    return Scaffold(
      appBar: AppBar(
        title: Text(_codeSent ? l10n.resetPassword : l10n.forgotPassword),
        leading: _codeSent
            ? IconButton(
                onPressed: isBusy ? null : _editEmail,
                icon: const Icon(Icons.arrow_back),
              )
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: _codeSent
              ? _buildConfirmStep(l10n, auth.errorMessage, isBusy)
              : _buildRequestStep(l10n, auth.errorMessage, isBusy),
        ),
      ),
    );
  }

  Widget _buildRequestStep(AppLocalizations l10n, String? error, bool isBusy) {
    return Form(
      key: _requestFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.forgotPassword, style: AppTypography.display),
          const SizedBox(height: AppSpacing.sm),
          Text(l10n.forgotPasswordHint, style: AppTypography.body),
          const SizedBox(height: AppSpacing.xxl),
          TextFormField(
            controller: _email,
            enabled: !isBusy,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            onFieldSubmitted: (_) => _requestCode(),
            decoration: InputDecoration(labelText: l10n.email),
            validator: (value) {
              final email = value?.trim() ?? '';
              if (email.isEmpty || !email.contains('@')) {
                return l10n.emailInvalid;
              }
              return null;
            },
          ),
          ..._errorAndButton(
            error: error,
            isBusy: isBusy,
            label: l10n.sendResetCode,
            onPressed: _requestCode,
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: isBusy ? null : () => context.go('/login'),
            child: Text(l10n.backToSignIn),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmStep(AppLocalizations l10n, String? error, bool isBusy) {
    return Form(
      key: _confirmFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.resetPassword, style: AppTypography.display),
          const SizedBox(height: AppSpacing.sm),
          Text(l10n.codeSentTo(_email.text.trim()), style: AppTypography.body),
          const SizedBox(height: AppSpacing.xl),
          TextFormField(
            controller: _code,
            enabled: !isBusy,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: l10n.verificationCode,
              counterText: '',
            ),
            validator: (value) =>
                value?.trim().length == 6 ? null : l10n.verificationCode,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _password,
            enabled: !isBusy,
            obscureText: _passwordHidden,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            decoration: InputDecoration(
              labelText: l10n.newPassword,
              helperText: l10n.passwordRequirements,
              helperMaxLines: 2,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() => _passwordHidden = !_passwordHidden);
                },
                icon: Icon(
                  _passwordHidden
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            validator: (value) => (value == null || value.length < 8)
                ? l10n.passwordTooShort
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _password2,
            enabled: !isBusy,
            obscureText: _password2Hidden,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            onFieldSubmitted: (_) => _confirmReset(),
            decoration: InputDecoration(
              labelText: l10n.confirmNewPassword,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() => _password2Hidden = !_password2Hidden);
                },
                icon: Icon(
                  _password2Hidden
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.confirmNewPassword;
              }
              if (value != _password.text) {
                return l10n.passwordsDoNotMatch;
              }
              return null;
            },
          ),
          ..._errorAndButton(
            error: error,
            isBusy: isBusy,
            label: l10n.resetPassword,
            onPressed: _confirmReset,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.didntGetCode, style: AppTypography.caption),
              TextButton(
                onPressed: isBusy ? null : _resendCode,
                child: Text(l10n.resendCode),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _errorAndButton({
    required String? error,
    required bool isBusy,
    required String label,
    required VoidCallback onPressed,
  }) {
    return [
      if (error != null) ...[
        const SizedBox(height: AppSpacing.md),
        Text(
          error,
          style: AppTypography.caption.copyWith(color: AppColors.primary),
        ),
      ],
      const SizedBox(height: AppSpacing.xl),
      isBusy
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2.5,
              ),
            )
          : AppButton(label: label, onPressed: onPressed, expanded: true),
    ];
  }
}
