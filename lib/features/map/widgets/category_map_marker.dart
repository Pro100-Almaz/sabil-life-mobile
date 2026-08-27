import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/listing.dart';

/// A compact point-of-interest badge that identifies a listing's category.
class CategoryMapMarker extends StatelessWidget {
  const CategoryMapMarker({
    required this.category,
    this.selected = false,
    super.key,
  });

  final CategoryType category;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppColors.surface : category.mapIconColor;
    final background = selected
        ? category.mapIconColor
        : category.mapBadgeColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: selected ? 40 : 34,
      height: selected ? 40 : 34,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surface, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x29000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        category.mapIcon,
        size: selected ? 23 : 20,
        color: foreground,
      ),
    );
  }
}

extension CategoryMapIcon on CategoryType {
  IconData get mapIcon => switch (this) {
    CategoryType.schools => Icons.school_rounded,
    CategoryType.nurseries => Icons.child_care_rounded,
    CategoryType.activities => Icons.sports_soccer_rounded,
    CategoryType.entertainment => Icons.local_activity_rounded,
    CategoryType.tutoring => Icons.co_present_rounded,
    CategoryType.masterclasses => Icons.palette_rounded,
    CategoryType.partnerships => Icons.storefront_rounded,
  };

  Color get mapIconColor => switch (this) {
    CategoryType.schools => const Color(0xFF28527A),
    CategoryType.nurseries => const Color(0xFF3F7D58),
    CategoryType.activities => const Color(0xFF176B87),
    CategoryType.entertainment => const Color(0xFF7950A3),
    CategoryType.tutoring => const Color(0xFF287271),
    CategoryType.masterclasses => const Color(0xFFB85C38),
    CategoryType.partnerships => const Color(0xFF4B5D92),
  };

  Color get mapBadgeColor => switch (this) {
    CategoryType.schools => const Color(0xFFDCEBFA),
    CategoryType.nurseries => const Color(0xFFE1F3E5),
    CategoryType.activities => const Color(0xFFDDF2F7),
    CategoryType.entertainment => const Color(0xFFF0E5F7),
    CategoryType.tutoring => const Color(0xFFDDF1EE),
    CategoryType.masterclasses => const Color(0xFFFBE8DC),
    CategoryType.partnerships => const Color(0xFFE4E8F5),
  };
}
