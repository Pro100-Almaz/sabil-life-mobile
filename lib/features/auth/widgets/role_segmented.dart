import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/auth_user.dart';

/// Family / Provider toggle on Register. When Provider is selected a second
/// row reveals tutor-vs-masterclass.
class RoleSegmented extends StatelessWidget {
  const RoleSegmented({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final UserRole selected;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isProvider = selected.isProvider;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PrimaryRow(
          isFamily: selected == UserRole.family,
          familyLabel: l10n.roleFamily,
          providerLabel: l10n.roleProvider,
          onSelectFamily: () => onChanged(UserRole.family),
          onSelectProvider: () => onChanged(UserRole.tutor),
        ),
        if (isProvider) ...[
          const SizedBox(height: AppSpacing.sm),
          _SecondaryRow(
            selected: selected,
            tutorLabel: l10n.roleTutor,
            masterclassLabel: l10n.roleMasterclass,
            onChanged: onChanged,
          ),
        ],
      ],
    );
  }
}

class _PrimaryRow extends StatelessWidget {
  const _PrimaryRow({
    required this.isFamily,
    required this.familyLabel,
    required this.providerLabel,
    required this.onSelectFamily,
    required this.onSelectProvider,
  });

  final bool isFamily;
  final String familyLabel;
  final String providerLabel;
  final VoidCallback onSelectFamily;
  final VoidCallback onSelectProvider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentButton(
              label: familyLabel,
              selected: isFamily,
              onTap: onSelectFamily,
            ),
          ),
          Expanded(
            child: _SegmentButton(
              label: providerLabel,
              selected: !isFamily,
              onTap: onSelectProvider,
            ),
          ),
        ],
      ),
    );
  }
}

class _SecondaryRow extends StatelessWidget {
  const _SecondaryRow({
    required this.selected,
    required this.tutorLabel,
    required this.masterclassLabel,
    required this.onChanged,
  });

  final UserRole selected;
  final String tutorLabel;
  final String masterclassLabel;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _OutlinedChoice(
            label: tutorLabel,
            selected: selected == UserRole.tutor,
            onTap: () => onChanged(UserRole.tutor),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _OutlinedChoice(
            label: masterclassLabel,
            selected: selected == UserRole.masterclass,
            onTap: () => onChanged(UserRole.masterclass),
          ),
        ),
      ],
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
        decoration: BoxDecoration(
          color: selected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          boxShadow: selected ? AppShadow.soft : null,
        ),
        alignment: Alignment.center,
        child: Text(label, style: AppTypography.label),
      ),
    );
  }
}

class _OutlinedChoice extends StatelessWidget {
  const _OutlinedChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.button),
          border: Border.all(
            color: selected ? AppColors.textPrimary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(label, style: AppTypography.label),
      ),
    );
  }
}
