import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/state/auth_provider.dart';
import '../../core/state/filter_provider.dart';
import '../../core/state/provider_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
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
  final Set<String> _ageGroups = {};
  final _pickedImages = <XFile>[];
  final _existingImages = <ListingImage>[];
  final _removedImageIds = <String>{};
  bool _saving = false;
  bool _showErrors = false;

  Listing? _existing;

  /// Rebuild so inline errors clear as the user fills required fields.
  void _onRequiredChanged() {
    if (_showErrors) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _existing = widget.initialListing;
    _title.addListener(_onRequiredChanged);
    _subtitle.addListener(_onRequiredChanged);
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
      _ageGroups.addAll(l.ageGroups);
      _existingImages.addAll(l.images);
    }
    if (_highlights.isEmpty) _highlights.add(TextEditingController());
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
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(
      maxWidth: 1600,
      imageQuality: 90,
    );
    if (!mounted || picked.isEmpty) return;
    setState(() {
      _pickedImages.addAll(picked);
    });
  }

  Future<void> _save({required bool submitForReview}) async {
    final user = ref.read(authProvider).user;
    if (user == null) return;
    if (_title.text.trim().isEmpty || _subtitle.text.trim().isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      setState(() => _showErrors = true);
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

      final base =
          _existing ??
          Listing(
            id:
                widget.listingId ??
                'listing-${DateTime.now().millisecondsSinceEpoch}',
            title: '',
            category: CategoryType.masterclasses,
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
        ageGroups: _ageGroups.toList(),
        status: ListingStatus.draft,
      );

      // 1. Save the listing fields (images are managed separately). Create
      //    first so a new listing has a server id before we attach images.

      final targetStatus = submitForReview && user.isVerified ? ListingStatus.pending : ListingStatus.draft;
      final repo = ref.read(providerRepositoryProvider);
      final saved = await repo.upsertListing(draft, status: targetStatus);

      // 2. Upload newly picked images to the saved listing.
      if (_pickedImages.isNotEmpty) {
        await repo.uploadListingImages(saved.id, [
          for (final image in _pickedImages) image.path,
        ]);
      }

      // 3. Delete the existing images the user removed, by id.
      for (final imageId in _removedImageIds) {
        await repo.deleteListingImage(saved.id, imageId);
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
              decoration: InputDecoration(
                labelText: l10n.fieldTitle,
                errorText: _showErrors && _title.text.trim().isEmpty
                    ? l10n.fieldRequired
                    : null,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _subtitle,
              decoration: InputDecoration(
                labelText: l10n.fieldSubtitle,
                errorText: _showErrors && _subtitle.text.trim().isEmpty
                    ? l10n.fieldRequired
                    : null,
              ),
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
            _ImageUploadSection(
              title: l10n.fieldAddImage,
              buttonLabel: l10n.fieldAddImage,
              existingImages: _existingImages,
              pickedImages: _pickedImages,
              onPick: _pickImages,
              onRemoveExisting: (index) => setState(() {
                _removedImageIds.add(_existingImages[index].id);
                _existingImages.removeAt(index);
              }),
              onRemovePicked: (index) => setState(() {
                _pickedImages.removeAt(index);
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

class _ImageUploadSection extends StatelessWidget {
  const _ImageUploadSection({
    required this.title,
    required this.buttonLabel,
    required this.existingImages,
    required this.pickedImages,
    required this.onPick,
    required this.onRemoveExisting,
    required this.onRemovePicked,
  });

  final String title;
  final String buttonLabel;
  final List<ListingImage> existingImages;
  final List<XFile> pickedImages;
  final Future<void> Function() onPick;
  final ValueChanged<int> onRemoveExisting;
  final ValueChanged<int> onRemovePicked;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: AppTypography.label),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: onPick,
          icon: const Icon(Icons.photo_library_outlined),
          label: Text(buttonLabel),
        ),
        if (existingImages.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (var i = 0; i < existingImages.length; i++)
                _ImageThumb(
                  image: Image.network(
                    existingImages[i].displayUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const ColoredBox(
                      color: AppColors.surfaceAlt,
                      child: SizedBox.expand(),
                    ),
                  ),
                  onRemove: () => onRemoveExisting(i),
                ),
            ],
          ),
        ],
        if (pickedImages.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (var i = 0; i < pickedImages.length; i++)
                _ImageThumb(
                  image: Image.file(
                    File(pickedImages[i].path),
                    fit: BoxFit.cover,
                  ),
                  onRemove: () => onRemovePicked(i),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ImageThumb extends StatelessWidget {
  const _ImageThumb({required this.image, this.onRemove});

  final Widget image;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: SizedBox(width: 92, height: 92, child: image),
        ),
        if (onRemove != null)
          Positioned(
            top: 4,
            right: 4,
            child: InkWell(
              onTap: onRemove,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
      ],
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
