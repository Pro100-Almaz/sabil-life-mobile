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

const _appLanguages = [
  (locale: Locale('en'), label: 'English'),
  (locale: Locale('ru'), label: 'Русский'),
  (locale: Locale('kk'), label: 'Қазақша'),
];

class ProviderSettingsScreen extends ConsumerWidget {
  const ProviderSettingsScreen({super.key, required this.interface});

  final ActiveInterface interface;

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
          // Verification banner
          profileAsync.maybeWhen(
            data: (profile) {
              if (profile.isVerified) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.sm,
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
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
          // Edit profile (tutor only — masterclass has no profile form yet).
          if (interface == ActiveInterface.tutor) ...[
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              leading: const Icon(
                Icons.person_outline,
                color: AppColors.textPrimary,
              ),
              title: Text(l10n.editProfile, style: AppTypography.body),
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
              onTap: () =>
                  context.push('${interface.basePath}/settings/edit-profile'),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Divider(),
            ),
          ],

          // Switch to the other provider interface (routed through its gate so
          // the target role's verification is checked first).
          if (interface == ActiveInterface.masterclass)
            _SwitchTile(
              icon: Icons.school_outlined,
              label: l10n.switchToTutor,
              onTap: () => context.push('/switch-to-tutor'),
            ),
          if (interface == ActiveInterface.tutor)
            _SwitchTile(
              icon: Icons.palette_outlined,
              label: l10n.switchToMasterclass,
              onTap: () => context.push('/switch-to-masterclass'),
            ),
          _SwitchTile(
            icon: Icons.home_outlined,
            label: l10n.switchToFamily,
            onTap: () {
              ref.read(activeInterfaceProvider.notifier).state =
                  ActiveInterface.family;
              context.go('/');
            },
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
          for (final language in _appLanguages)
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

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(label, style: AppTypography.body),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
