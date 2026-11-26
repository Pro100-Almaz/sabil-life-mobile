import 'package:flutter/material.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/util/legal_links.dart';

/// Privacy policy and support rows shared by both settings screens.
class LegalLinkTiles extends StatelessWidget {
  const LegalLinkTiles({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final links = [
      (Icons.privacy_tip_outlined, l10n.privacyPolicy, privacyPolicyUri),
      (Icons.help_outline, l10n.support, supportUri),
    ];
    return Column(
      children: [
        for (final (icon, label, uri) in links)
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
            ),
            leading: Icon(icon, color: AppColors.textPrimary),
            title: Text(label, style: AppTypography.body),
            trailing: const Icon(
              Icons.open_in_new,
              size: 20,
              color: AppColors.textSecondary,
            ),
            onTap: () => openLegalLink(context, uri),
          ),
      ],
    );
  }
}
