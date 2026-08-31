import 'package:flutter/material.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';

Future<bool?> showDeleteAccountDialog({
  required BuildContext context,
  required Future<String?> Function(String password) onDelete,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _DeleteAccountDialog(onDelete: onDelete),
  );
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog({required this.onDelete});

  final Future<String?> Function(String password) onDelete;

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() => _errorMessage = l10n.deleteAccountPasswordRequired);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final error = await widget.onDelete(password);
    if (!mounted) return;

    if (error == null) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _isSubmitting = false;
      _errorMessage = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.deleteAccountTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.deleteAccountWarning),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            enabled: !_isSubmitting,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              if (!_isSubmitting) _submit();
            },
            decoration: InputDecoration(
              labelText: l10n.currentPassword,
              hintText: l10n.deleteAccountPasswordHint,
              errorText: _errorMessage,
              suffixIcon: IconButton(
                onPressed: _isSubmitting
                    ? null
                    : () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting
              ? null
              : () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryPressed,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.deleteAccountConfirm),
        ),
      ],
    );
  }
}
