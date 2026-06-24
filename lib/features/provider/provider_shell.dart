import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/state/auth_provider.dart';
import '../../core/theme/app_colors.dart';

class ProviderShell extends StatelessWidget {
  const ProviderShell({
    super.key,
    required this.navigationShell,
    required this.interface,
  });

  final StatefulNavigationShell navigationShell;

  /// Which provider interface this shell renders. The two interfaces share a
  /// layout today but are kept separate so they can diverge later.
  final ActiveInterface interface;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
          // Item order must match the branch order in app_router.dart:
          // tutor drops "listings", masterclass drops "inquiries".
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_outlined),
              label: l10n.dashboard,
            ),
            if (interface == ActiveInterface.masterclass)
              BottomNavigationBarItem(
                icon: const Icon(Icons.list_alt_outlined),
                label: l10n.myListings,
              ),
            if (interface == ActiveInterface.tutor)
              BottomNavigationBarItem(
                icon: const Icon(Icons.inbox_outlined),
                label: l10n.inquiries,
              ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.payments_outlined),
              label: l10n.earnings,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              label: l10n.providerSettings,
            ),
          ],
        ),
      ),
    );
  }
}
