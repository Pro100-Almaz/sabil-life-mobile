import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/state/auth_provider.dart';
import '../../core/state/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/auth_user.dart';
import '../../shared/widgets/legal_link_tiles.dart';
import 'delete_account_dialog.dart';

const _languages = [
  (locale: Locale('en'), label: 'English'),
  (locale: Locale('ru'), label: 'Русский'),
  (locale: Locale('kk'), label: 'Қазақша'),
];

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _showAbout(BuildContext context) async {
    final info = await PackageInfo.fromPlatform();
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context)!;
    showAboutDialog(
      context: context,
      applicationName: l10n.appName,
      applicationVersion: '${l10n.version} ${info.version}',
      children: [Text(l10n.aboutAppSubtitle, style: AppTypography.body)],
    );
  }

  void _openProviderArea(
    BuildContext context,
    WidgetRef ref,
    AuthUser user,
    ActiveInterface interface,
  ) {
    final hasRole = switch (interface) {
      ActiveInterface.tutor => user.hasTutorRole,
      ActiveInterface.masterclass => user.hasMasterclassRole,
      ActiveInterface.family => true,
    };

    // Existing provider accounts can access their workspace immediately. The
    // dashboard itself keeps unverified providers in draft-only mode. Families
    // still go through the appropriate provider application flow.
    if (hasRole) {
      ref.read(activeInterfaceProvider.notifier).state = interface;
      context.go(interface.basePath);
      return;
    }
    context.push(
      interface == ActiveInterface.tutor
          ? '/switch-to-tutor'
          : '/switch-to-masterclass',
    );
  }

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

            if (user.isFamily)
              ListTile(
                leading: const Icon(Icons.notifications_active_outlined),
                title: Text(l10n.followedProviders),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/followed-providers'),
              ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              leading: const Icon(
                Icons.home_outlined,
                color: AppColors.textPrimary,
              ),
              title: Text(
                user.homeLocation == null
                    ? l10n.setHomeLocation
                    : l10n.changeHomeLocation,
                style: AppTypography.body,
              ),
              subtitle: Text(
                l10n.homeLocationSubtitle,
                style: AppTypography.small,
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
              onTap: () => context.push('/settings/home-location'),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              leading: const Icon(
                Icons.person_outline,
                color: AppColors.textPrimary,
              ),
              title: Text(
                "Edit personal information",
                style: AppTypography.body,
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
              onTap: () => context.push('/edit-personal-information'),
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
              onTap: () =>
                  _openProviderArea(context, ref, user, ActiveInterface.tutor),
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
              onTap: () => _openProviderArea(
                context,
                ref,
                user,
                ActiveInterface.masterclass,
              ),
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
            onTap: () => _showAbout(context),
          ),
          const LegalLinkTiles(),
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
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              leading: const Icon(
                Icons.delete_forever_outlined,
                color: AppColors.primaryPressed,
              ),
              title: Text(
                l10n.deleteAccount,
                style: AppTypography.body.copyWith(
                  color: AppColors.primaryPressed,
                ),
              ),
              onTap: () async {
                final deleted = await showDeleteAccountDialog(
                  context: context,
                  onDelete: (password) => ref
                      .read(authProvider.notifier)
                      .deleteAccount(password: password),
                );
                if (deleted == true && context.mounted) context.go('/');
              },
            ),
          ],
        ],
      ),
    );
  }
}
