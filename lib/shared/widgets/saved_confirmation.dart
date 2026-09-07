import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';

void showSavedConfirmation(BuildContext context) {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        elevation: 4,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        padding: EdgeInsets.zero,
        shape: const StadiumBorder(),
        duration: const Duration(seconds: 4),
        content: SavedConfirmationBanner(
          message: AppLocalizations.of(context)!.savedToFavorites,
          onTap: () {
            messenger.hideCurrentSnackBar();
            context.go('/favorites');
          },
        ),
      ),
    );
}

class SavedConfirmationBanner extends StatelessWidget {
  const SavedConfirmationBanner({
    required this.message,
    required this.onTap,
    super.key,
  });

  final String message;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: message,
    child: InkWell(
      onTap: onTap,
      customBorder: const StadiumBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        child: Row(
          children: [
            const Icon(Icons.favorite, color: Colors.white, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white, size: 24),
          ],
        ),
      ),
    ),
  );
}
