import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// A highlight bullet: check icon + text.
class InfoTile extends StatelessWidget {
  const InfoTile({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 20,
            color: AppColors.success,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(text, style: AppTypography.body)),
        ],
      ),
    );
  }
}
