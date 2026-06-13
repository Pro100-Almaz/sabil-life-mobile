import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../shared/widgets/star_rating.dart';

/// ★ rating · "{n} reviews", localized.
class RatingRow extends StatelessWidget {
  const RatingRow({super.key, required this.rating, required this.reviewCount});

  final double rating;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StarRating(rating: rating, suffix: l10n.reviews(reviewCount));
  }
}
