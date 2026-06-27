import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/state/auth_provider.dart';
import '../../../data/models/auth_user.dart';
import '../../../data/models/tutor.dart';
import '../../../shared/widgets/app_button.dart';
import '../../auth/widgets/auth_sheet.dart';

/// Family CTA on the tutor profile — JIT-auths if needed, then opens the tutor
/// inquiry composer. Providers viewing a tutor don't see this CTA.
class TutorInquireCta extends ConsumerWidget {
  const TutorInquireCta({super.key, required this.tutor, this.expanded = true});

  final Tutor tutor;
  final bool expanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);

    // Providers don't send inquiries to tutors via this CTA.
    if (auth.user?.role == UserRole.tutor ||
        auth.user?.role == UserRole.masterclass) {
      return const SizedBox.shrink();
    }

    return AppButton(
      label: l10n.inquire,
      icon: Icons.send_outlined,
      expanded: expanded,
      onPressed: () async {
        final ok = await presentAuthSheet(context, ref);
        if (!ok || !context.mounted) return;
        // Close the profile sheet, then open the composer.
        Navigator.of(context).pop();
        context.push('/inquire/tutor/${tutor.id}', extra: tutor);
      },
    );
  }
}
