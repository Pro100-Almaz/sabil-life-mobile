import 'package:flutter/material.dart';
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
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _goBack() {
    if (context.canPop()){
      context.pop();
    }else {
      context.go('/');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref
        .read(authProvider.notifier)
        .register(
          email: _email.text,
          password: _password.text,
          fullName: _name.text,
        );
    if (!mounted) return;
    if (ok) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);
    final isBusy = auth.status == AuthStatus.authenticating;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.register)),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: AppSpacing.lg,
              left: AppSpacing.lg,
              child: FloatingActionButton(
                heroTag: 'go_back',
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.textPrimary,
                elevation: 2,
                onPressed: _goBack,
                child: const Icon(Icons.arrow_back_ios, size: 20),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                      validator: (v) =>
                          (v == null || !v.contains('@')) ? l10n.email : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      enabled: !isBusy,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(labelText: l10n.password),
                      validator: (v) =>
                          (v == null || v.length < 6) ? l10n.password : null,
                    ),
                    if (auth.errorMessage != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        auth.errorMessage!,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primary,
                        ),
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
                        : AppButton(
                            label: l10n.createAccount,
                            onPressed: _submit,
                            expanded: true,
                          ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(l10n.haveAccountPrompt, style: AppTypography.caption),
                        TextButton(
                          onPressed: isBusy ? null : () => context.go('/login'),
                          child: Text(l10n.signIn),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ]
        ),
      ),
    );
  }
}
