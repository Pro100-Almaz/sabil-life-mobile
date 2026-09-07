import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../core/state/auth_provider.dart";
import "../../core/theme/app_spacing.dart";
import "../../shared/widgets/app_button.dart";

/// Replaces the password-only screen with verified personal-information edits.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _password2 = TextEditingController();
  final _code = TextEditingController();
  bool _verifying = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _name.text = user?.fullName ?? "";
    _email.text = user?.email ?? "";
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _password2.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    final user = ref.read(authProvider).user;
    if (user == null) return;
    final name = _name.text.trim() == user.fullName ? "" : _name.text.trim();
    final email = _email.text.trim().toLowerCase() == user.email.toLowerCase()
        ? ""
        : _email.text.trim();
    final password = _password.text;
    if (name.isEmpty && email.isEmpty && password.isEmpty) {
      setState(() => _error = "Change at least one field.");
      return;
    }
    if (password.isNotEmpty && password != _password2.text) {
      setState(() => _error = "Passwords do not match.");
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final error = await ref
        .read(authProvider.notifier)
        .requestPersonalInformationChange(
          newName: name,
          newEmail: email,
          newPassword: password,
          newPassword2: _password2.text,
        );
    if (!mounted) return;
    setState(() {
      _saving = false;
      _error = error;
      _verifying = error == null;
    });
  }

  Future<void> _confirm() async {
    if (_code.text.trim().length != 6) {
      setState(() => _error = "Enter the 6-digit verification code.");
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final passwordChanged = _password.text.isNotEmpty;
    final error = await ref
        .read(authProvider.notifier)
        .confirmPersonalInformationChange(
          code: _code.text,
          passwordChanged: passwordChanged,
        );
    if (!mounted) return;
    if (error == null) {
      if (passwordChanged) {
        context.go("/login");
      } else {
        context.pop();
      }
      return;
    }
    setState(() {
      _saving = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _verifying ? "Verify changes" : "Edit personal information",
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_verifying) ...[
                const Text(
                  "Enter the 6-digit code sent to your current email address.",
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: _code,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  enabled: !_saving,
                  decoration: const InputDecoration(
                    labelText: "Verification code",
                  ),
                ),
              ] else ...[
                TextField(
                  controller: _name,
                  enabled: !_saving,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _email,
                  enabled: !_saving,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _password,
                  enabled: !_saving,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "New password",
                    helperText: "Leave blank to keep your password",
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _password2,
                  enabled: !_saving,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Confirm new password",
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              if (_saving)
                const Center(child: CircularProgressIndicator())
              else
                AppButton(
                  label: _verifying
                      ? "Verify changes"
                      : "Send verification code",
                  expanded: true,
                  onPressed: _verifying ? _confirm : _requestCode,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
