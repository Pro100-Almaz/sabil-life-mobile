import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/state/auth_provider.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_button.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _newPassword2 = TextEditingController();

  bool _oldHidden = true;
  bool _newHidden = true;
  bool _new2Hidden = true;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _oldPassword.dispose();
    _newPassword.dispose();
    _newPassword2.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    final error = await ref
        .read(authProvider.notifier)
        .changePassword(
          oldPassword: _oldPassword.text,
          newPassword: _newPassword.text,
          newPassword2: _newPassword2.text,
        );

    if (!mounted) return;

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.passwordChangedSignInAgain,
          ),
        ),
      );
      context.go('/login');
      return;
    }

    setState(() {
      _saving = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.changePassword)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PasswordField(
                  controller: _oldPassword,
                  label: l10n.currentPassword,
                  hidden: _oldHidden,
                  enabled: !_saving,
                  onToggle: () => setState(() => _oldHidden = !_oldHidden),
                  validator: (value) => value == null || value.isEmpty
                      ? l10n.fieldRequired
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                _PasswordField(
                  controller: _newPassword,
                  label: l10n.newPassword,
                  hidden: _newHidden,
                  enabled: !_saving,
                  helperText: l10n.passwordRequirements,
                  onToggle: () => setState(() => _newHidden = !_newHidden),
                  validator: (value) => value == null || value.length < 8
                      ? l10n.passwordTooShort
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                _PasswordField(
                  controller: _newPassword2,
                  label: l10n.confirmNewPassword,
                  hidden: _new2Hidden,
                  enabled: !_saving,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  onToggle: () => setState(() => _new2Hidden = !_new2Hidden),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.fieldRequired;
                    }
                    if (value != _newPassword.text) {
                      return l10n.passwordsDoNotMatch;
                    }
                    return null;
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                if (_saving)
                  const Center(child: CircularProgressIndicator())
                else
                  AppButton(
                    label: l10n.changePassword,
                    expanded: true,
                    onPressed: _submit,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.hidden,
    required this.enabled,
    required this.onToggle,
    required this.validator,
    this.helperText,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final bool hidden;
  final bool enabled;
  final VoidCallback onToggle;
  final String? Function(String?) validator;
  final String? helperText;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: hidden,
      textInputAction: textInputAction,
      autofillHints: const [AutofillHints.password],
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        helperMaxLines: 2,
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
        ),
      ),
      validator: validator,
    );
  }
}
