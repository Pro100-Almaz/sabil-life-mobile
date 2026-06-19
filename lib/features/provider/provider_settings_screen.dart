import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/state/auth_provider.dart';
import '../../core/state/locale_provider.dart';
import '../../core/state/provider_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/app_button.dart';

const _languages = [
  (locale: Locale('en'), label: 'English'),
  (locale: Locale('ru'), label: 'Русский'),
  (locale: Locale('kk'), label: 'Қазақша'),
];

class ProviderSettingsScreen extends ConsumerWidget {
  const ProviderSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authProvider).user;
    final currentLocale = ref.watch(localeProvider);
    final profileAsync = ref.watch(providerProfileProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.providerSettings)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          if (user != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.fullName, style: AppTypography.h3),
                  Text(user.email, style: AppTypography.caption),
                ],
              ),
            ),
            const Divider(),
          ],
          // Profile edit section
          profileAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(e.toString(), style: AppTypography.caption),
            ),
            data: (profile) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!profile.isVerified) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      0,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              l10n.providerUnverifiedBanner,
                              style: AppTypography.small.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                _ProfileEditSection(profile: profile),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Divider(),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
            ),
            leading: const Icon(
              Icons.home_outlined,
              color: AppColors.textPrimary,
            ),
            title: Text(l10n.switchToFamily, style: AppTypography.body),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
            onTap: () => context.go('/?as=family'),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Divider(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Text(l10n.language, style: AppTypography.h3),
          ),
          for (final language in _languages)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              title: Text(language.label, style: AppTypography.body),
              trailing:
                  currentLocale.languageCode == language.locale.languageCode
                  ? const Icon(Icons.check_circle, color: AppColors.primary)
                  : const Icon(Icons.circle_outlined, color: AppColors.border),
              onTap: () =>
                  ref.read(localeProvider.notifier).state = language.locale,
            ),
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Divider(),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
            ),
            leading: const Icon(Icons.logout, color: AppColors.primary),
            title: Text(
              l10n.signOut,
              style: AppTypography.body.copyWith(color: AppColors.primary),
            ),
            onTap: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/');
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileEditSection extends ConsumerStatefulWidget {
  const _ProfileEditSection({required this.profile});

  final dynamic profile;

  @override
  ConsumerState<_ProfileEditSection> createState() =>
      _ProfileEditSectionState();
}

class _ProfileEditSectionState extends ConsumerState<_ProfileEditSection> {
  late final TextEditingController _displayNameCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _subjectsCtrl;
  late final TextEditingController _rateCtrl;
  late final TextEditingController _availabilityCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _displayNameCtrl = TextEditingController(text: p.displayName as String);
    _bioCtrl = TextEditingController(text: p.bio as String);
    _subjectsCtrl = TextEditingController(
      text: (p.subjects as List<String>).join(', '),
    );
    _rateCtrl = TextEditingController(
      text: p.hourlyRateQar != null ? '${p.hourlyRateQar}' : '',
    );
    _availabilityCtrl = TextEditingController(text: p.availability as String);
  }

  @override
  void dispose() {
    _displayNameCtrl.dispose();
    _bioCtrl.dispose();
    _subjectsCtrl.dispose();
    _rateCtrl.dispose();
    _availabilityCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final subjects = _subjectsCtrl.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      final rateRaw = int.tryParse(_rateCtrl.text.trim());
      await ref
          .read(providerRepositoryProvider)
          .updateProfile(
            displayName: _displayNameCtrl.text.trim(),
            bio: _bioCtrl.text.trim(),
            subjects: subjects,
            hourlyRateQar: rateRaw,
            availability: _availabilityCtrl.text.trim(),
          );
      ref.invalidate(providerProfileProvider);
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.providerProfileSaved)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),
          _Field(label: l10n.displayName, controller: _displayNameCtrl),
          const SizedBox(height: AppSpacing.md),
          _Field(label: l10n.bio, controller: _bioCtrl, maxLines: 3),
          const SizedBox(height: AppSpacing.md),
          _Field(label: l10n.subjects, controller: _subjectsCtrl),
          const SizedBox(height: AppSpacing.md),
          _Field(
            label: l10n.hourlyRate,
            controller: _rateCtrl,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.md),
          _Field(label: l10n.availability, controller: _availabilityCtrl),
          const SizedBox(height: AppSpacing.lg),
          _saving
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : AppButton(label: l10n.save, onPressed: _save),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.caption),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: AppTypography.body,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ],
    );
  }
}
