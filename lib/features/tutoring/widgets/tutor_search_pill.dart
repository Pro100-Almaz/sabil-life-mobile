import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/state/tutor_filter_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Airbnb-style search pill for the Tutoring page. Drives
/// `tutorFilterProvider.search`, which feeds the backend `search` param.
class TutorSearchPill extends ConsumerStatefulWidget {
  const TutorSearchPill({super.key});

  @override
  ConsumerState<TutorSearchPill> createState() => _TutorSearchPillState();
}

class _TutorSearchPillState extends ConsumerState<TutorSearchPill> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(tutorFilterProvider).search,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final query = ref.watch(tutorFilterProvider.select((f) => f.search));

    if (_controller.text != query) {
      _controller.text = query;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.chip),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadow.soft,
      ),
      child: TextField(
        controller: _controller,
        onSubmitted: (value) {
          ref.read(tutorFilterProvider.notifier).setSearch(value);
        },
        style: AppTypography.body,
        decoration: InputDecoration(
          filled: false,
          hintText: l10n.searchTutorsHint,
          prefixIcon: const Icon(Icons.search, color: AppColors.textPrimary),
          suffixIcon: query.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    _controller.clear();
                    ref.read(tutorFilterProvider.notifier).setSearch('');
                  },
                ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md + 2,
          ),
        ),
      ),
    );
  }
}
