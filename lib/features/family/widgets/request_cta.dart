import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/state/auth_provider.dart';
import '../../../data/models/auth_user.dart';
import '../../../shared/widgets/app_button.dart';
import '../../auth/widgets/auth_sheet.dart';

/// Family CTA — JIT-auths if needed, then navigates to the inquiry composer.
/// Providers viewing a tutoring/masterclass listing don't see this CTA.
class RequestCta extends ConsumerWidget {
  const RequestCta({
    super.key,
    required this.listingId,
    this.tutorIdHint,
    this.expanded = true,
  });

  final String listingId;
  final String? tutorIdHint;
  final bool expanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);

    // Providers don't request from other listings via this CTA.
    if (auth.user?.role == UserRole.tutor ||
        auth.user?.role == UserRole.masterclass) {
      return const SizedBox.shrink();
    }

    return AppButton(
      label: l10n.request,
      icon: Icons.send_outlined,
      expanded: expanded,
      onPressed: () async {
        final ok = await presentAuthSheet(context, ref);
        if (!ok || !context.mounted) return;
        final query = tutorIdHint != null ? '?tutor=$tutorIdHint' : '';
        context.push('/inquiry/$listingId$query');
      },
    );
  }
}
