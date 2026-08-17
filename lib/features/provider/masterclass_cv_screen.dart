import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/state/provider_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/auth_user.dart';
import '../../shared/widgets/app_button.dart';

class MasterclassCvScreen extends ConsumerStatefulWidget {
  const MasterclassCvScreen({super.key});

  @override
  ConsumerState<MasterclassCvScreen> createState() =>
      _MasterclassCvScreenState();
}

class _MasterclassCvScreenState extends ConsumerState<MasterclassCvScreen> {
  PlatformFile? _cv;
  bool _submitting = false;
  String? _error;

  Future<void> _pickCv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      allowMultiple: false,
      withData: false,
    );
    if (!mounted || result == null) return;

    final file = result.files.single;
    if (file.path == null || !file.name.toLowerCase().endsWith('.pdf')) {
      setState(() => _error = AppLocalizations.of(context)!.cvPdfOnly);
      return;
    }
    setState(() {
      _cv = file;
      _error = null;
    });
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final path = _cv?.path;
    if (path == null) {
      setState(() => _error = l10n.cvRequired);
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref
          .read(providerRepositoryProvider)
          .requestVerification(UserRole.masterclass, cvPath: path);
      ref.invalidate(myVerificationsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.masterclassRequestSent)));
      context.pop();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.submitCv)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          children: [
            Text(l10n.masterclassCvTitle, style: AppTypography.h2),
            const SizedBox(height: AppSpacing.sm),
            Text(l10n.masterclassCvInstructions, style: AppTypography.body),
            const SizedBox(height: AppSpacing.xl),
            InkWell(
              onTap: _submitting ? null : _pickCv,
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.picture_as_pdf_outlined,
                      size: 48,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _cv?.name ?? l10n.choosePdfCv,
                      style: AppTypography.body,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            if (_submitting)
              const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            else
              AppButton(
                label: l10n.submitApplication,
                onPressed: _submit,
                expanded: true,
              ),
          ],
        ),
      ),
    );
  }
}
