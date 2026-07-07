import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/state/city_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/city.dart';

/// City picker with type-ahead suggestions over the bundled city list.
///
/// Search matches names in the **current app language**, but only a city that
/// exists in the list can be chosen — free text never resolves to a value.
/// Emits the selected [City] (or `null` when the field is cleared/invalid) via
/// [onChanged]; the parent persists [City.backendValue] (e.g. `"Doha, QA"`).
class CityAutocompleteField extends ConsumerStatefulWidget {
  const CityAutocompleteField({
    super.key,
    required this.onChanged,
    this.initialBackendValue,
    this.errorText,
  });

  /// Existing stored value (`"Doha, QA"`) to prefill, if any.
  final String? initialBackendValue;
  final ValueChanged<City?> onChanged;

  /// Inline validation message shown under the field (coral) when non-null.
  final String? errorText;

  @override
  ConsumerState<CityAutocompleteField> createState() =>
      _CityAutocompleteFieldState();
}

class _CityAutocompleteFieldState extends ConsumerState<CityAutocompleteField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  List<City> _allCities = const [];
  String _query = '';
  City? _selected;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _loadCities();
  }

  void _onFocusChange() {
    // Leaving the field rejects any unconfirmed text — the input only *finds*
    // a city; the value is the one tapped from the list. Revert to the selected
    // city's name (or empty) so free text is never kept.
    if (!_focusNode.hasFocus) {
      _query = '';
      final text = _selected?.localizedName(_languageCode) ?? '';
      if (_controller.text != text) _controller.text = text;
    }
    setState(() {});
  }

  Future<void> _loadCities() async {
    final cities = await ref.read(cityRepositoryProvider).all();
    if (!mounted) return;
    setState(() {
      _allCities = cities;
      final initial = widget.initialBackendValue;
      if (initial != null && initial.isNotEmpty) {
        for (final c in cities) {
          if (c.backendValue == initial) {
            _selected = c;
            _controller.text = c.localizedName(_languageCode);
            break;
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String get _languageCode => Localizations.localeOf(context).languageCode;

  List<City> get _matches {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _allCities;
    return _allCities
        .where((c) => c.localizedName(_languageCode).toLowerCase().contains(q))
        .toList();
  }

  void _onChangedText(String value) {
    setState(() {
      _query = value;
      // Any manual edit invalidates a prior pick — only a tap selects a city.
      if (_selected != null &&
          value != _selected!.localizedName(_languageCode)) {
        _selected = null;
        widget.onChanged(null);
      }
    });
  }

  void _select(City city) {
    setState(() {
      _selected = city;
      _query = city.localizedName(_languageCode);
      _controller.text = _query;
    });
    _focusNode.unfocus();
    widget.onChanged(city);
  }

  void _clear() {
    setState(() {
      _selected = null;
      _query = '';
      _controller.clear();
    });
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final showSuggestions =
        _focusNode.hasFocus && _selected == null && _allCities.isNotEmpty;
    final matches = _matches;
    final hasError = widget.errorText != null;
    final borderColor = hasError ? AppColors.primary : AppColors.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.cityLabel,
          style: AppTypography.caption.copyWith(
            color: hasError ? AppColors.primary : null,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          style: AppTypography.body,
          onChanged: _onChangedText,
          decoration: InputDecoration(
            hintText: l10n.citySearchHint,
            prefixIcon: const Icon(Icons.location_city_outlined, size: 20),
            suffixIcon: _controller.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    color: AppColors.textSecondary,
                    onPressed: _clear,
                  ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
              borderSide: BorderSide(color: borderColor),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              widget.errorText!,
              style: AppTypography.small.copyWith(color: AppColors.primary),
            ),
          ),
        if (showSuggestions) ...[
          const SizedBox(height: AppSpacing.xs),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.border),
              boxShadow: AppShadow.soft,
            ),
            constraints: const BoxConstraints(maxHeight: 240),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: Material(
                type: MaterialType.transparency,
                child: matches.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search_off,
                              size: 18,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              l10n.cityNoResults,
                              style: AppTypography.small.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: matches.length,
                        separatorBuilder: (_, _) =>
                            const Divider(height: 1, color: AppColors.divider),
                        itemBuilder: (context, index) {
                          final city = matches[index];
                          return ListTile(
                            dense: true,
                            title: Text(
                              city.localizedName(_languageCode),
                              style: AppTypography.body,
                            ),
                            trailing: Text(
                              city.country,
                              style: AppTypography.small.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                            onTap: () => _select(city),
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
