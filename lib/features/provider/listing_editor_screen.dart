import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/state/auth_provider.dart';
import '../../core/state/filter_provider.dart';
import '../../core/state/provider_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/util/listing_contact.dart';
import '../../data/mock/mock_home.dart';
import '../../data/models/listing.dart';
import '../../shared/widgets/app_button.dart';

import 'widgets/listing_location_map.dart';

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
  final _url = TextEditingController();
  final _registrationUrl = TextEditingController();
  final _contacts = <_ContactInput>[];

  bool _isOnline = true;
  MasterclassEventType? _eventType;
  DateTime? _startsAt;
  bool _saving = false;
  bool _showErrors = false;
  LatLng _pickedLocation = defaultDohaCenter;

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
    _url.addListener(_onRequiredChanged);
    _registrationUrl.addListener(_onRequiredChanged);
    _neighborhood.addListener(_onRequiredChanged);

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
      _pickedLocation = LatLng(l.lat, l.lng);
      _isOnline = l.isOnline;
      _url.text = l.meetingUrl;
      _registrationUrl.text = l.registrationUrl;
      for (final contact in l.contacts) {
        _contacts.add(
          _ContactInput(
            type: contact.type,
            value: contact.value,
            label: contact.label,
          ),
        );
      }
      _eventType = l.eventType;
      _startsAt = l.startsAt;
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
    _url.dispose();
    _registrationUrl.dispose();
    for (final contact in _contacts) {
      contact.dispose();
    }
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

  bool _isValidOptionalUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return true;

    final uri = Uri.tryParse(trimmed);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  String _contactTypeLabel(AppLocalizations l10n, ListingContactType type) {
    return switch (type) {
      ListingContactType.phone => l10n.contactPhone,
      ListingContactType.email => l10n.email,
      ListingContactType.website => l10n.contactWebsite,
      ListingContactType.whatsapp => l10n.contactWhatsApp,
      ListingContactType.instagram => l10n.contactInstagram,
      ListingContactType.telegram => l10n.contactTelegram,
    };
  }

  String? _contactError(AppLocalizations l10n, _ContactInput contact) {
    return switch (validateListingContact(contact.type, contact.value.text)) {
      'required' => l10n.fieldRequired,
      'email' => l10n.emailInvalid,
      'phone' => l10n.contactInvalidPhone,
      'url' => l10n.invalidUrl,
      _ => null,
    };
  }

  bool get _hasDuplicateContacts {
    final seen = <String>{};
    for (final contact in _contacts) {
      final value = contact.value.text.trim().toLowerCase();
      if (value.isEmpty) continue;
      final identity = '${contact.type.name}:$value';
      if (!seen.add(identity)) return true;
    }
    return false;
  }

  Future<void> _chooseEventType(MasterclassEventType eventType) async {
    if (eventType == MasterclassEventType.oneTime &&
        _eventType != MasterclassEventType.oneTime) {
      final l10n = AppLocalizations.of(context)!;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.oneTimeEventWarningTitle),
          content: Text(l10n.oneTimeEventWarningMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.continueLabel),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }
    setState(() => _eventType = eventType);
  }

  Future<void> _chooseStartDateTime() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(now.year + 5, 12, 31);
    var initial = _startsAt ?? now.add(const Duration(days: 1));
    if (initial.isBefore(firstDate)) {
      initial = now.add(const Duration(days: 1));
    } else if (initial.isAfter(lastDate)) {
      initial = lastDate;
    }
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !mounted) return;

    setState(() {
      _startsAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _save({required bool submitForReview}) async {
    final user = ref.read(authProvider).user;
    final missingCore =
        _title.text.trim().isEmpty || _subtitle.text.trim().isEmpty;
    final missingUrl = _isOnline && _url.text.trim().isEmpty;
    final missingLocation = !_isOnline && _neighborhood.text.trim().isEmpty;
    final invalidRegistrationUrl = !_isValidOptionalUrl(_registrationUrl.text);
    final invalidContacts = _contacts.any(
      (contact) =>
          validateListingContact(contact.type, contact.value.text) != null,
    );
    final missingEventType = _eventType == null;
    final invalidStartsAt =
        _startsAt == null || !_startsAt!.isAfter(DateTime.now());

    if (user == null) return;
    if (missingCore ||
        missingLocation ||
        missingUrl ||
        invalidRegistrationUrl ||
        invalidContacts ||
        _hasDuplicateContacts ||
        missingEventType ||
        invalidStartsAt) {
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
            lat: _pickedLocation.latitude,
            lng: _pickedLocation.longitude,
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
        lat: _pickedLocation.latitude,
        lng: _pickedLocation.longitude,
        priceFromQar: price,
        description: _description.text.trim(),
        highlights: highlights,
        ageGroups: _ageGroups.toList(),
        status: ListingStatus.draft,
        isOnline: _isOnline,
        meetingUrl: _isOnline ? _url.text.trim() : '',
        registrationUrl: _registrationUrl.text.trim(),
        contacts: [
          for (var index = 0; index < _contacts.length; index++)
            ListingContact(
              type: _contacts[index].type,
              value: _contacts[index].value.text.trim(),
              label: _contacts[index].label.text.trim(),
              position: index,
            ),
        ],
        eventType: _eventType!,
        startsAt: () => _startsAt,
      );

      // 1. Save the listing fields (images are managed separately). Create
      //    first so a new listing has a server id before we attach images.

      final targetStatus = submitForReview && user.isVerified
          ? ListingStatus.pending
          : ListingStatus.draft;
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
            Text(l10n.eventScheduleTitle, style: AppTypography.h3),
            const SizedBox(height: AppSpacing.xs),
            Text(l10n.eventTypePrompt, style: AppTypography.body),
            const SizedBox(height: AppSpacing.md),
            SegmentedButton<MasterclassEventType>(
              style: SegmentedButton.styleFrom(
                foregroundColor: AppColors.primary,
                selectedForegroundColor: Colors.white,
                selectedBackgroundColor: AppColors.primary,
              ),
              segments: [
                ButtonSegment(
                  value: MasterclassEventType.oneTime,
                  icon: const Icon(Icons.event_outlined),
                  label: Text(l10n.eventOneTime),
                ),
                ButtonSegment(
                  value: MasterclassEventType.ongoing,
                  icon: const Icon(Icons.event_repeat_outlined),
                  label: Text(l10n.eventOngoing),
                ),
              ],
              selected: _eventType == null ? {} : {_eventType!},
              emptySelectionAllowed: true,
              onSelectionChanged: (selection) {
                if (selection.isNotEmpty) {
                  _chooseEventType(selection.first);
                }
              },
            ),
            if (_showErrors && _eventType == null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.eventTypeRequired,
                style: AppTypography.caption.copyWith(color: AppColors.primary),
              ),
            ],
            if (_eventType != null) ...[
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: _chooseStartDateTime,
                icon: const Icon(Icons.schedule_outlined),
                label: Text(
                  _startsAt == null
                      ? l10n.chooseEventDateTime
                      : '${MaterialLocalizations.of(context).formatFullDate(_startsAt!)} · ${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(_startsAt!))}',
                ),
              ),
              if (_showErrors &&
                  (_startsAt == null ||
                      !_startsAt!.isAfter(DateTime.now()))) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.futureEventDateRequired,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ],
            const SizedBox(height: AppSpacing.xxl),
            //Title
            TextField(
              controller: _title,
              decoration: InputDecoration(
                label: Text.rich(
                  TextSpan(
                    text: l10n.fieldTitle,
                    children: [
                      TextSpan(
                        text: "*",
                        style: const TextStyle(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                errorText: _showErrors && _title.text.trim().isEmpty
                    ? l10n.fieldRequired
                    : null,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            //Subtitle
            TextField(
              controller: _subtitle,
              decoration: InputDecoration(
                label: Text.rich(
                  TextSpan(
                    text: l10n.fieldSubtitle,
                    children: [
                      TextSpan(
                        text: "*",
                        style: const TextStyle(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                errorText: _showErrors && _subtitle.text.trim().isEmpty
                    ? l10n.fieldRequired
                    : null,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SegmentedButton<bool>(
              style: SegmentedButton.styleFrom(
                foregroundColor: AppColors.primary,
                selectedForegroundColor: Colors.white,
                selectedBackgroundColor: AppColors.primary,
              ),
              segments: [
                ButtonSegment(value: true, label: Text(l10n.fieldOnline)),
                ButtonSegment(value: false, label: Text(l10n.fieldOffline)),
              ],
              selected: {_isOnline},
              onSelectionChanged: (s) => setState(() => _isOnline = s.first),
            ),
            const SizedBox(height: AppSpacing.md),
            if (_isOnline) ...[
              TextField(
                controller: _url,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  label: Text.rich(
                    TextSpan(
                      text: l10n.fieldUrl,
                      children: [
                        TextSpan(
                          text: "*",
                          style: const TextStyle(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  errorText:
                      _showErrors && _isOnline && _url.text.trim().isEmpty
                      ? l10n.fieldRequired
                      : null,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            if (!_isOnline) ...[
              TextField(
                controller: _neighborhood,
                decoration: InputDecoration(
                  label: Text.rich(
                    TextSpan(
                      text: l10n.fieldNeighborhood,
                      children: [
                        TextSpan(
                          text: "*",
                          style: const TextStyle(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  errorText:
                      _showErrors &&
                          !_isOnline &&
                          _neighborhood.text.trim().isEmpty
                      ? l10n.fieldRequired
                      : null,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ListingLocationMap(
                initialLocation: _pickedLocation,
                onLocationPicked: (point) => _pickedLocation = point,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            TextField(
              controller: _registrationUrl,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: l10n.fieldRegistrationUrl,
                hintText: 'https://example.com/register',
                helperText: l10n.fieldRegistrationUrlOptional,
                errorText:
                    _showErrors && !_isValidOptionalUrl(_registrationUrl.text)
                    ? l10n.invalidUrl
                    : null,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(l10n.contactInformation, style: AppTypography.h3),
            const SizedBox(height: AppSpacing.xs),
            Text(l10n.contactInformationOptional, style: AppTypography.caption),
            const SizedBox(height: AppSpacing.md),
            for (var index = 0; index < _contacts.length; index++) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<ListingContactType>(
                            initialValue: _contacts[index].type,
                            decoration: InputDecoration(
                              labelText: l10n.contactType,
                            ),
                            items: [
                              for (final type in ListingContactType.values)
                                DropdownMenuItem(
                                  value: type,
                                  child: Text(_contactTypeLabel(l10n, type)),
                                ),
                            ],
                            onChanged: (type) {
                              if (type != null) {
                                setState(() => _contacts[index].type = type);
                              }
                            },
                          ),
                        ),
                        IconButton(
                          tooltip: l10n.remove,
                          onPressed: () => setState(() {
                            final contact = _contacts.removeAt(index);
                            contact.dispose();
                          }),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _contacts[index].value,
                      keyboardType: switch (_contacts[index].type) {
                        ListingContactType.phone => TextInputType.phone,
                        ListingContactType.email => TextInputType.emailAddress,
                        _ => TextInputType.url,
                      },
                      autocorrect: false,
                      onChanged: (_) {
                        if (_showErrors) setState(() {});
                      },
                      decoration: InputDecoration(
                        labelText: l10n.contactValue,
                        hintText: switch (_contacts[index].type) {
                          ListingContactType.phone => '+974 5555 1234',
                          ListingContactType.email => 'hello@example.com',
                          _ => 'https://example.com',
                        },
                        errorText: _showErrors
                            ? _contactError(l10n, _contacts[index])
                            : null,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _contacts[index].label,
                      decoration: InputDecoration(
                        labelText: l10n.contactLabel,
                        hintText: l10n.contactLabelHint,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            OutlinedButton.icon(
              onPressed: _contacts.length >= 20
                  ? null
                  : () => setState(() => _contacts.add(_ContactInput())),
              icon: const Icon(Icons.add),
              label: Text(l10n.addContact),
            ),
            if (_showErrors && _hasDuplicateContacts) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.duplicateContact,
                style: AppTypography.caption.copyWith(color: AppColors.primary),
              ),
            ],
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

class _ContactInput {
  _ContactInput({
    this.type = ListingContactType.phone,
    String value = '',
    String label = '',
  }) : value = TextEditingController(text: value),
       label = TextEditingController(text: label);

  ListingContactType type;
  final TextEditingController value;
  final TextEditingController label;

  void dispose() {
    value.dispose();
    label.dispose();
  }
}
