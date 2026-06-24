import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/state/auth_provider.dart';
import '../../core/state/provider_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'widgets/tutor_profile_form.dart';

class TutorProfileEditScreen extends ConsumerWidget {
  const TutorProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authProvider).user;
    if (user == null) return const SizedBox.shrink();

    final detailAsync = ref.watch(tutorDetailForUserProvider(user.id));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editProfile)),
      body: detailAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(e.toString(), style: AppTypography.caption),
          ),
        ),
        data: (detail) => TutorProfileForm(
          userId: user.id,
          headerMessage: '',
          existingProfile: detail,
          submitLabel: l10n.save,
          showGoBackButton: false,
          popOnSave: true,
        ),
      ),
    );
  }
}
