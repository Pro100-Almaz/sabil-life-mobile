import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/state/auth_provider.dart';
import '../../core/state/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

const _languages = [
  (locale: Locale('en'), label: 'English'),
  (locale: Locale('ru'), label: 'Русский'),
  (locale: Locale('kk'), label: 'Қазақша'),
];

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    final auth = ref.watch(authProvider);
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navSettings, style: AppTypography.display),
        toolbarHeight: 72,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          if (user == null)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.authSheetHint,
                        style: AppTypography.caption,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    TextButton(
                      onPressed: () => context.push('/login'),
                      child: Text(l10n.signIn),
                    ),
                  ],
                ),
              ),
            )
          else ...[
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
                  Text(l10n.signedInAs(user.fullName), style: AppTypography.h3),
                  Text(user.email, style: AppTypography.caption),
                ],
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              leading: const Icon(
                Icons.inbox_outlined,
                color: AppColors.textPrimary,
              ),
              title: Text(l10n.myRequests, style: AppTypography.body),
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
              onTap: () => context.push('/my-requests'),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              leading: const Icon(
                Icons.school_outlined,
                color: AppColors.textPrimary,
              ),
              title: Text(l10n.switchToTutor, style: AppTypography.body),
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
              onTap: () => context.push('/switch-to-tutor'),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              leading: const Icon(
                Icons.palette_outlined,
                color: AppColors.textPrimary,
              ),
              title: Text(l10n.switchToMasterclass, style: AppTypography.body),
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
              onTap: () => context.push('/switch-to-masterclass'),
            ),
            const Divider(),
          ],
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
            ),
            leading: const Icon(
              Icons.lightbulb_outline,
              color: AppColors.textPrimary,
            ),
            title: Text(l10n.suggestService, style: AppTypography.body),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
            onTap: () =>
                context.push(auth.isAuthenticated ? '/suggest' : '/login'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
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
              vertical: AppSpacing.lg,
            ),
            child: Divider(),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
            ),
            leading: const Icon(
              Icons.info_outline,
              color: AppColors.textPrimary,
            ),
            title: Text(l10n.about, style: AppTypography.body),
            subtitle: Text(l10n.aboutAppSubtitle, style: AppTypography.small),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: l10n.appName,
              applicationVersion: '${l10n.version} 1.0.0',
              children: [
                Text(l10n.aboutAppSubtitle, style: AppTypography.body),
              ],
            ),
          ),
          if (user != null) ...[
            const Divider(),
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
              },
            ),
          ],
        ],
      ),
    );
  }
}
