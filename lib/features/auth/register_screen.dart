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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _code = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  /// False while collecting name/email/password; true once a code has been
  /// emailed and we're waiting for the user to enter it.
  bool _codeSent = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _code.dispose();
    super.dispose();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  /// Step 1 → validate the form and request a verification code.
  Future<void> _requestCode() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref
        .read(authProvider.notifier)
        .requestRegistrationCode(
          email: _email.text,
          password: _password.text,
          fullName: _name.text,
        );
    if (!mounted) return;
    if (ok) {
      setState(() => _codeSent = true);
    }
  }

  /// Step 2 → confirm the code; on success the account is created + signed in.
  Future<void> _verifyCode() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref
        .read(authProvider.notifier)
        .confirmRegistration(email: _email.text, code: _code.text.trim());
    if (!mounted) return;
    if (ok) {
      context.go('/');
    }
  }

  Future<void> _resendCode() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await ref
        .read(authProvider.notifier)
        .requestRegistrationCode(
          email: _email.text,
          password: _password.text,
          fullName: _name.text,
        );
    if (!mounted || !ok) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.codeResent)));
  }

  void _editDetails() {
    _code.clear();
    setState(() => _codeSent = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);
    final isBusy = auth.status == AuthStatus.authenticating;

    return Scaffold(
      appBar: AppBar(
        title: Text(_codeSent ? l10n.verifyEmailTitle : l10n.register),
        leading: _codeSent
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: isBusy ? null : _editDetails,
              )
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _codeSent
                  ? _verifyStep(l10n, isBusy, auth.errorMessage)
                  : _detailsStep(l10n, isBusy, auth.errorMessage),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _detailsStep(AppLocalizations l10n, bool isBusy, String? error) {
    return [
      Text(l10n.createAccount, style: AppTypography.display),
      const SizedBox(height: AppSpacing.xl),
      TextFormField(
        controller: _name,
        textInputAction: TextInputAction.next,
        enabled: !isBusy,
        decoration: InputDecoration(labelText: l10n.fullName),
        validator: (v) =>
            (v == null || v.trim().isEmpty) ? l10n.fullName : null,
      ),
      const SizedBox(height: AppSpacing.md),
      TextFormField(
        controller: _email,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        enabled: !isBusy,
        decoration: InputDecoration(labelText: l10n.email),
        validator: (v) => (v == null || !v.contains('@')) ? l10n.email : null,
      ),
      const SizedBox(height: AppSpacing.md),
      TextFormField(
        controller: _password,
        obscureText: true,
        textInputAction: TextInputAction.done,
        enabled: !isBusy,
        onFieldSubmitted: (_) => _requestCode(),
        decoration: InputDecoration(labelText: l10n.password),
        validator: (v) => (v == null || v.length < 6) ? l10n.password : null,
      ),
      ..._errorAndActions(
        isBusy,
        error: error,
        label: l10n.continueLabel,
        onPressed: _requestCode,
      ),
      const SizedBox(height: AppSpacing.lg),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(l10n.haveAccountPrompt, style: AppTypography.caption),
          TextButton(
            onPressed: isBusy ? null : _goBack,
            child: Text(l10n.signIn),
          ),
        ],
      ),
    ];
  }

  List<Widget> _verifyStep(AppLocalizations l10n, bool isBusy, String? error) {
    return [
      Text(l10n.verifyEmailTitle, style: AppTypography.display),
      const SizedBox(height: AppSpacing.sm),
      Text(l10n.codeSentTo(_email.text), style: AppTypography.body),
      const SizedBox(height: AppSpacing.xl),
      TextFormField(
        controller: _code,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        enabled: !isBusy,
        maxLength: 6,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onFieldSubmitted: (_) => _verifyCode(),
        decoration: InputDecoration(
          labelText: l10n.verificationCode,
          counterText: '',
        ),
        validator: (v) =>
            (v == null || v.trim().length != 6) ? l10n.verificationCode : null,
      ),
      ..._errorAndActions(
        isBusy,
        error: error,
        label: l10n.verify,
        onPressed: _verifyCode,
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
    ];
  }

  /// The error message + primary action button, shared by both steps.
  List<Widget> _errorAndActions(
    bool isBusy, {
    required String? error,
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
