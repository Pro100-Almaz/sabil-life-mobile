import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/state/auth_provider.dart';
import '../../core/state/filter_provider.dart';
import '../../core/state/provider_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/auth_user.dart';
import '../../data/models/listing.dart';
import '../../shared/widgets/app_button.dart';

class ListingEditorScreen extends ConsumerStatefulWidget {
  const ListingEditorScreen({
    super.key,
    required this.listingId,
    this.initialListing,
  });

  /// Null = create a new listing.
  final String? listingId;
  final Listing? initialListing;

  @override
  ConsumerState<ListingEditorScreen> createState() =>
      _ListingEditorScreenState();
}

class _ListingEditorScreenState extends ConsumerState<ListingEditorScreen> {
  final _title = TextEditingController();
  final _subtitle = TextEditingController();
  final _neighborhood = TextEditingController(text: 'West Bay, Doha');
  final _price = TextEditingController(text: '0');
  final _description = TextEditingController();
  final _highlights = <TextEditingController>[];
  final _images = <TextEditingController>[];
  final Set<String> _ageGroups = {};
  bool _saving = false;

  Listing? _existing;

  @override
  void initState() {
    super.initState();
    _existing = widget.initialListing;
    final l = _existing;
    if (l != null) {
      _title.text = l.title;
      _subtitle.text = l.subtitle;
      _neighborhood.text = l.neighborhood;
      _price.text = '${l.priceFromQar}';
      _description.text = l.description;
      for (final h in l.highlights) {
        _highlights.add(TextEditingController(text: h));
      }
      for (final url in l.imageUrls) {
        _images.add(TextEditingController(text: url));
      }
      _ageGroups.addAll(l.ageGroups);
    }
    if (_highlights.isEmpty) _highlights.add(TextEditingController());
    if (_images.isEmpty) _images.add(TextEditingController());
  }

  @override
  void dispose() {
    _title.dispose();
    _subtitle.dispose();
    _neighborhood.dispose();
    _price.dispose();
    _description.dispose();
    for (final c in _highlights) {
      c.dispose();
    }
    for (final c in _images) {
      c.dispose();
    }
    super.dispose();
  }

  CategoryType _categoryFor(UserRole role) => role == UserRole.masterclass
      ? CategoryType.masterclasses
      : CategoryType.tutoring;

  Future<void> _save({required bool submitForReview}) async {
    final user = ref.read(authProvider).user;
    if (user == null) return;
    if (_title.text.trim().isEmpty || _subtitle.text.trim().isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.fillRequiredFields)));
      return;
    }

    setState(() => _saving = true);
    try {
      final price = int.tryParse(_price.text.trim()) ?? 0;
      final highlights = _highlights
          .map((c) => c.text.trim())
          .where((h) => h.isNotEmpty)
          .toList();
      final images = _images
          .map((c) => c.text.trim())
          .where((u) => u.isNotEmpty)
          .toList();
      final fallbackImage =
          'https://picsum.photos/seed/${user.id}-${DateTime.now().millisecondsSinceEpoch}/800/600';

      final base =
          _existing ??
          Listing(
            id:
                widget.listingId ??
                'listing-${DateTime.now().millisecondsSinceEpoch}',
            title: '',
            category: _categoryFor(user.role),
            subtitle: '',
            neighborhood: '',
            lat: 25.3690,
            lng: 51.5510,
            rating: 0,
            reviewCount: 0,
            priceFromQar: 0,
            imageUrls: const [],
            ageGroups: const [],
            isFeatured: false,
            description: '',
            highlights: const [],
            ownerId: user.id,
            status: ListingStatus.draft,
          );

      final draft = base.copyWith(
        title: _title.text.trim(),
        subtitle: _subtitle.text.trim(),
        neighborhood: _neighborhood.text.trim(),
        priceFromQar: price,
        description: _description.text.trim(),
        highlights: highlights,
        imageUrls: images.isEmpty ? [fallbackImage] : images,
        ageGroups: _ageGroups.toList(),
        status: ListingStatus.draft,
      );

      final saved = await ref
          .read(providerRepositoryProvider)
          .upsertListing(draft);
      if (submitForReview && user.isVerified) {
        await ref.read(providerRepositoryProvider).submitForReview(saved.id);
      }

      ref.invalidate(myListingsProvider(user.id));
      if (!mounted) return;
      context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authProvider).user;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: Text(_existing == null ? l10n.newListing : l10n.editListing),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          children: [
            TextField(
              controller: _title,
              decoration: InputDecoration(labelText: l10n.fieldTitle),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _subtitle,
              decoration: InputDecoration(labelText: l10n.fieldSubtitle),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _neighborhood,
              decoration: InputDecoration(labelText: l10n.fieldNeighborhood),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _price,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.fieldPrice),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _description,
              maxLines: 5,
              decoration: InputDecoration(labelText: l10n.fieldDescription),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.ageGroup, style: AppTypography.label),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final age in kAgeGroups)
                  FilterChip(
                    label: Text(age),
                    selected: _ageGroups.contains(age),
                    onSelected: (on) => setState(() {
                      if (on) {
                        _ageGroups.add(age);
                      } else {
                        _ageGroups.remove(age);
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _RepeatableSection(
              title: l10n.fieldHighlights,
              addLabel: l10n.fieldAddHighlight,
              controllers: _highlights,
              onAdd: () =>
                  setState(() => _highlights.add(TextEditingController())),
              onRemove: (i) => setState(() {
                final c = _highlights.removeAt(i);
                c.dispose();
              }),
            ),
            const SizedBox(height: AppSpacing.lg),
            _RepeatableSection(
              title: l10n.fieldImageUrl,
              addLabel: l10n.fieldAddImage,
              controllers: _images,
              onAdd: () => setState(() => _images.add(TextEditingController())),
              onRemove: (i) => setState(() {
                final c = _images.removeAt(i);
                c.dispose();
              }),
            ),
            const SizedBox(height: AppSpacing.xxl),
            if (!user.isVerified) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Text(
                  l10n.draftCanOnlySubmitWhenVerified,
                  style: AppTypography.caption,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            if (_saving)
              const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            else
              Column(
                children: [
                  AppButton(
                    label: l10n.submitForReview,
                    expanded: true,
                    onPressed: !user.isVerified
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l10n.draftCanOnlySubmitWhenVerified,
                                ),
                              ),
                            );
                          }
                        : () => _save(submitForReview: true),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    label: l10n.saveDraft,
                    variant: AppButtonVariant.outlined,
                    expanded: true,
                    onPressed: () => _save(submitForReview: false),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _RepeatableSection extends StatelessWidget {
  const _RepeatableSection({
    required this.title,
    required this.addLabel,
    required this.controllers,
    required this.onAdd,
    required this.onRemove,
  });

  final String title;
  final String addLabel;
  final List<TextEditingController> controllers;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: AppTypography.label),
        const SizedBox(height: AppSpacing.sm),
        for (var i = 0; i < controllers.length; i++) ...[
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controllers[i],
                  decoration: const InputDecoration(),
                ),
              ),
              if (controllers.length > 1)
                IconButton(
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => onRemove(i),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text(addLabel),
          ),
        ),
      ],
    );
  }
}
