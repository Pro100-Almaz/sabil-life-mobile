import 'package:flutter/material.dart';

import '../../../shared/widgets/pill_chip.dart';
import '../../../data/repositories/catalog_repository.dart';
import '../../../core/theme/app_spacing.dart';

class TagGroupRail extends StatefulWidget {
  const TagGroupRail({
    required this.groups,
    required this.selectedTags,
    required this.onToggleTag,
    required this.onClear,
    super.key,
  });

  final List<TagGroup> groups;
  final Set<String> selectedTags;
  final ValueChanged<String> onToggleTag;
  final VoidCallback onClear;

  @override
  State<TagGroupRail> createState() => _TagGroupRailState();
}

class _TagGroupRailState extends State<TagGroupRail> {
  String? expandedGroup;

  @override
  Widget build(BuildContext context) {
    final visibleTags = expandedGroup == null
        ? const <String>[]
        : widget.groups.firstWhere((group) => group.name == expandedGroup).tags;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              SizedBox(width: AppSpacing.sm),
              PillChip(
                label: 'All',
                selected: widget.selectedTags.isEmpty,
                onTap: widget.onClear,
              ),
              for (final group in widget.groups) ...[
                SizedBox(width: AppSpacing.sm),
                PillChip(
                  label: group.name,
                  selected:
                      expandedGroup == group.name ||
                      group.tags.any(widget.selectedTags.contains),
                  onTap: () {
                    setState(() {
                      expandedGroup = expandedGroup == group.name
                          ? null
                          : group.name;
                    });
                  },
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        if (expandedGroup != null)
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final tag in visibleTags) ...[
                  SizedBox(width: AppSpacing.sm),
                  PillChip(
                    label: tag,
                    selected: widget.selectedTags.contains(tag),
                    onTap: () => widget.onToggleTag(tag),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
