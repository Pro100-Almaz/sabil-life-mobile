import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/state/filter_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Airbnb-style search pill: an inline text field that drives
/// `filterProvider.query` live, with a clear (✕) button.
class SearchPill extends ConsumerStatefulWidget {
  const SearchPill({super.key});

  @override
  ConsumerState<SearchPill> createState() => _SearchPillState();
}

class _SearchPillState extends ConsumerState<SearchPill> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(filterProvider).query);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final query = ref.watch(filterProvider.select((f) => f.query));

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
        onChanged: (value) => ref.read(filterProvider.notifier).setQuery(value),
        style: AppTypography.body,
        decoration: InputDecoration(
          filled: false,
          hintText: l10n.searchHint,
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
                    ref.read(filterProvider.notifier).setQuery('');
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
