import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Read-only ★ + numeric rating (Airbnb style: dark star, not gold).
class StarRating extends StatelessWidget {
  const StarRating({super.key, required this.rating, this.suffix});

  final double rating;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star, size: 14, color: AppColors.star),
        const SizedBox(width: 4),
        Text(rating.toStringAsFixed(1), style: AppTypography.label),
        if (suffix != null) ...[
          Text(' · ', style: AppTypography.caption),
          Text(suffix!, style: AppTypography.caption),
        ],
      ],
    );
  }
}
