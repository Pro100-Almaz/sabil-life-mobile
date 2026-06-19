import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/state/provider_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/suggestion.dart';

/// The 7 backend category keys shown in the suggestion form.
const _kCategoryKeys = [
  'SCHOOLS',
  'NURSERIES',
  'ACTIVITIES',
  'ENTERTAINMENT',
  'TUTORING',
  'MASTERCLASSES',
  'PARTNERSHIPS',
];

class SuggestionScreen extends ConsumerStatefulWidget {
  const SuggestionScreen({super.key});

  @override
  ConsumerState<SuggestionScreen> createState() => _SuggestionScreenState();
}

class _SuggestionScreenState extends ConsumerState<SuggestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _neighborhoodController = TextEditingController();

  String? _selectedCategory; // null = "Any"
  bool _submitting = false;

  @override
  void dispose() {
    _messageController.dispose();
    _neighborhoodController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    try {
      await ref
          .read(suggestionRepositoryProvider)
          .submit(
            category: _selectedCategory,
            neighborhood: _neighborhoodController.text.trim().isEmpty
                ? null
                : _neighborhoodController.text.trim(),
            message: _messageController.text.trim(),
          );
      if (!mounted) return;
      ref.invalidate(mySuggestionsProvider);
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.suggestionSubmitted),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _formKey.currentState?.reset();
      _messageController.clear();
      _neighborhoodController.clear();
      setState(() => _selectedCategory = null);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final suggestionsAsync = ref.watch(mySuggestionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.suggestService, style: AppTypography.display),
        toolbarHeight: 72,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(l10n.suggestServiceHint, style: AppTypography.caption),
          const SizedBox(height: AppSpacing.lg),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Category dropdown
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.suggestionCategory,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: _selectedCategory,
                      isExpanded: true,
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text(l10n.suggestionCategoryAny),
                        ),
                        ..._kCategoryKeys.map(
                          (key) =>
                              DropdownMenuItem(value: key, child: Text(key)),
                        ),
                      ],
                      onChanged: (v) => setState(() => _selectedCategory = v),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Neighborhood field
                TextFormField(
                  controller: _neighborhoodController,
                  decoration: InputDecoration(
                    labelText: l10n.suggestionNeighborhood,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Message field (required)
                TextFormField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    labelText: l10n.suggestionMessage,
                    hintText: l10n.suggestionMessageHint,
                    border: const OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.fillRequiredFields
                      : null,
                ),
                const SizedBox(height: AppSpacing.lg),

                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.button),
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(l10n.suggestionSubmit),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),
          Text(l10n.mySuggestions, style: AppTypography.h3),
          const SizedBox(height: AppSpacing.sm),

          suggestionsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text(
              e.toString(),
              style: AppTypography.caption.copyWith(color: AppColors.primary),
            ),
            data: (suggestions) {
              if (suggestions.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Text(
                    '—',
                    style: AppTypography.caption,
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return Column(
                children: suggestions
                    .map((s) => _SuggestionTile(suggestion: s))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({required this.suggestion});

  final Suggestion suggestion;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      elevation: 0,
      color: AppColors.surfaceAlt,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (suggestion.category.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      suggestion.category,
                      style: AppTypography.small.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                _StatusBadge(status: suggestion.status, l10n: l10n),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(suggestion.message, style: AppTypography.body),
            if (suggestion.neighborhood.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                suggestion.neighborhood,
                style: AppTypography.small.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.l10n});

  final SuggestionStatus status;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      SuggestionStatus.new_ => (
        l10n.suggestionStatusNew,
        AppColors.textSecondary,
      ),
      SuggestionStatus.reviewed => (l10n.suggestionStatusReviewed, Colors.blue),
      SuggestionStatus.actedOn => (l10n.suggestionStatusActedOn, Colors.green),
      SuggestionStatus.dismissed => (
        l10n.suggestionStatusDismissed,
        AppColors.primary,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTypography.small.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
