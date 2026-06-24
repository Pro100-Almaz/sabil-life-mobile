import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/state/filter_provider.dart';
import '../../../core/state/provider_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/util/tutor_label.dart';
import '../../../data/models/provider_profile.dart';
import '../../../data/models/tutor.dart';
import '../../../shared/widgets/app_button.dart';

const _tutorLanguages = [
  'EN',
  'AR',
  'RU',
  'FR',
  'ES',
  'DE',
  'ZH',
  'HI',
  'UR',
  'KK',
];

class TutorProfileForm extends ConsumerStatefulWidget {
  const TutorProfileForm({
    super.key,
    required this.userId,
    required this.headerMessage,
    this.existingProfile,
    this.submitLabel,
    this.showGoBackButton = true,
    this.popOnSave = false,
  });

  final String userId;
  final String headerMessage;
  final ProviderProfile? existingProfile;
  final String? submitLabel;
  final bool showGoBackButton;

  /// When true, pop back to the previous screen after a successful save
  /// instead of staying on the form.
  final bool popOnSave;

  @override
  ConsumerState<TutorProfileForm> createState() => _TutorProfileFormState();
}

class _TutorProfileFormState extends ConsumerState<TutorProfileForm> {
  late final TextEditingController _displayNameCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _rateCtrl;
  late final TextEditingController _availabilityCtrl;
  late final TextEditingController _credentialsCtrl;
  late final TextEditingController _yearsCtrl;
  late final TextEditingController _customSubjectCtrl;

  Set<String> _selectedSubjects = {};
  final Set<String> _customSubjects = {};
  Set<TutorFormat> _selectedFormats = {};
  Set<String> _selectedAgeGroups = {};
  Set<String> _selectedLanguages = {};
  bool _trialAvailable = false;
  bool _showOtherSubjectField = false;

  String _avatarUrl = '';
  File? _pickedAvatarFile;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _displayNameCtrl = TextEditingController();
    _bioCtrl = TextEditingController();
    _rateCtrl = TextEditingController();
    _availabilityCtrl = TextEditingController();
    _credentialsCtrl = TextEditingController();
    _yearsCtrl = TextEditingController();
    _customSubjectCtrl = TextEditingController();

    final p = widget.existingProfile;
    if (p != null) _prefill(p);
  }

  void _prefill(ProviderProfile p) {
    _displayNameCtrl.text = p.displayName;
    _bioCtrl.text = p.bio;
    _rateCtrl.text = p.hourlyRateQar != null ? '${p.hourlyRateQar}' : '';
    _availabilityCtrl.text = p.availability;
    _credentialsCtrl.text = p.credentials;
    _yearsCtrl.text = p.yearsExperience > 0 ? '${p.yearsExperience}' : '';
    _trialAvailable = p.trialAvailable;
    _avatarUrl = p.avatarUrl;
    _selectedSubjects = p.subjects.toSet();
    _selectedFormats = p.formats
        .map(_formatFromBackend)
        .whereType<TutorFormat>()
        .toSet();
    _selectedAgeGroups = p.ageGroups.toSet();
    _selectedLanguages = p.languages.toSet();
  }

  @override
  void dispose() {
    _displayNameCtrl.dispose();
    _bioCtrl.dispose();
    _rateCtrl.dispose();
    _availabilityCtrl.dispose();
    _credentialsCtrl.dispose();
    _yearsCtrl.dispose();
    _customSubjectCtrl.dispose();
    super.dispose();
  }

  static TutorFormat? _formatFromBackend(String raw) =>
      switch (raw.toUpperCase()) {
        'ONE_ON_ONE' => TutorFormat.oneOnOne,
        'SMALL_GROUP' => TutorFormat.smallGroup,
        'AT_CENTRE' => TutorFormat.atCentre,
        'ONLINE' => TutorFormat.online,
        _ => null,
      };

  static String _formatToBackend(TutorFormat f) => switch (f) {
    TutorFormat.oneOnOne => 'ONE_ON_ONE',
    TutorFormat.smallGroup => 'SMALL_GROUP',
    TutorFormat.atCentre => 'AT_CENTRE',
    TutorFormat.online => 'ONLINE',
  };

  void _addCustomSubject() {
    final text = _customSubjectCtrl.text.trim().toUpperCase();
    if (text.isEmpty) return;
    setState(() {
      _customSubjects.add(text);
      _selectedSubjects.add(text);
      _customSubjectCtrl.clear();
    });
  }

  Future<void> _pickAvatar() async {
    final l10n = AppLocalizations.of(context)!;
    const removeAction = 'remove';
    final result = await showModalBottomSheet<Object>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.photoFromGallery),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(l10n.photoFromCamera),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            if (_pickedAvatarFile != null || _avatarUrl.isNotEmpty)
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppColors.primary,
                ),
                title: Text(
                  l10n.removePhoto,
                  style: const TextStyle(color: AppColors.primary),
                ),
                onTap: () => Navigator.pop(context, removeAction),
              ),
          ],
        ),
      ),
    );

    if (!mounted || result == null) return;

    if (result == removeAction) {
      setState(() {
        _pickedAvatarFile = null;
        _avatarUrl = '';
      });
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: result as ImageSource,
      maxWidth: 512,
    );
    if (picked != null && mounted) {
      setState(() {
        _pickedAvatarFile = File(picked.path);
      });
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;

    if (_selectedSubjects.isEmpty ||
        _selectedFormats.isEmpty ||
        _selectedAgeGroups.isEmpty ||
        _rateCtrl.text.trim().isEmpty ||
        _yearsCtrl.text.trim().isEmpty ||
        _selectedLanguages.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.fillRequiredFields)));
      return;
    }

    setState(() => _saving = true);
    try {
      final repo = ref.read(providerRepositoryProvider);

      var avatarUrl = _avatarUrl;
      var isUpdate = widget.existingProfile != null;
      if (_pickedAvatarFile != null) {
        avatarUrl = await repo.uploadAvatar(_pickedAvatarFile!.path);
        if (avatarUrl.isNotEmpty) {
          isUpdate = true;
        }
      }

      final method = isUpdate ? repo.updateTutorDetail : repo.createTutorDetail;
      await method(
        displayName: _displayNameCtrl.text.trim(),
        bio: _bioCtrl.text.trim(),
        subjects: _selectedSubjects.toList(),
        hourlyRateQar: int.tryParse(_rateCtrl.text.trim()),
        availability: _availabilityCtrl.text.trim(),
        formats: _selectedFormats.map(_formatToBackend).toList(),
        ageGroups: _selectedAgeGroups.toList(),
        languages: _selectedLanguages.toList(),
        yearsExperience: int.tryParse(_yearsCtrl.text.trim()) ?? 0,
        credentials: _credentialsCtrl.text.trim(),
        avatarUrl: avatarUrl,
        trialAvailable: _trialAvailable,
      );

      ref.invalidate(tutorDetailForUserProvider(widget.userId));
      // Saving tutor-detail auto-creates/updates the verification server-side.
      ref.invalidate(myVerificationsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.profileSubmittedForReview)));
      if (widget.popOnSave && context.canPop()) context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final asyncSubjects = ref.watch(availableSubjectsProvider);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      children: [
        const SizedBox(height: AppSpacing.lg),
        Text(widget.headerMessage, style: AppTypography.body),
        const SizedBox(height: AppSpacing.lg),

        // Avatar
        Text(l10n.profileAvatar, style: AppTypography.caption),
        const SizedBox(height: AppSpacing.sm),
        Center(
          child: GestureDetector(
            onTap: _pickAvatar,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.surfaceAlt,
                  backgroundImage: _pickedAvatarFile != null
                      ? FileImage(_pickedAvatarFile!)
                      : (_avatarUrl.isNotEmpty
                            ? NetworkImage(_avatarUrl) as ImageProvider
                            : null),
                  child: (_pickedAvatarFile == null && _avatarUrl.isEmpty)
                      ? const Icon(
                          Icons.person_outline,
                          size: 40,
                          color: AppColors.textTertiary,
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.textPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: AppColors.surface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Subjects
        Text(l10n.subjects, style: AppTypography.caption),
        const SizedBox(height: AppSpacing.xs),
        asyncSubjects.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
          error: (_, _) =>
              Text(l10n.genericLoadError, style: AppTypography.small),
          data: (backendSubjects) {
            final allSubjects = <String>{
              ...backendSubjects,
              ..._customSubjects,
            };
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final subject in allSubjects)
                      _ToggleChip(
                        label: subjectLabel(subject, l10n),
                        selected: _selectedSubjects.contains(subject),
                        onTap: () => setState(() {
                          if (!_selectedSubjects.remove(subject)) {
                            _selectedSubjects.add(subject);
                          }
                        }),
                      ),
                    _ToggleChip(
                      label: l10n.other,
                      selected: _showOtherSubjectField,
                      onTap: () => setState(() {
                        _showOtherSubjectField = !_showOtherSubjectField;
                      }),
                    ),
                  ],
                ),
                if (_showOtherSubjectField) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _customSubjectCtrl,
                          style: AppTypography.body,
                          decoration: InputDecoration(
                            hintText: l10n.addCustomSubject,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadius.card,
                              ),
                              borderSide: const BorderSide(
                                color: AppColors.border,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadius.card,
                              ),
                              borderSide: const BorderSide(
                                color: AppColors.border,
                              ),
                            ),
                          ),
                          onSubmitted: (_) => _addCustomSubject(),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      IconButton(
                        onPressed: _addCustomSubject,
                        icon: const Icon(Icons.add_circle_outline),
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),

        // Formats
        Text(l10n.profileFormats, style: AppTypography.caption),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final format in TutorFormat.values)
              _ToggleChip(
                label: format.label(l10n),
                selected: _selectedFormats.contains(format),
                onTap: () => setState(() {
                  if (!_selectedFormats.remove(format)) {
                    _selectedFormats.add(format);
                  }
                }),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Age groups
        Text(l10n.profileAgeGroups, style: AppTypography.caption),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final age in kAgeGroups)
              _ToggleChip(
                label: age,
                selected: _selectedAgeGroups.contains(age),
                onTap: () => setState(() {
                  if (!_selectedAgeGroups.remove(age)) {
                    _selectedAgeGroups.add(age);
                  }
                }),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Price per hour
        _Field(
          label: l10n.hourlyRate,
          controller: _rateCtrl,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: AppSpacing.md),

        // Years experience
        _Field(
          label: l10n.profileYearsExperience,
          controller: _yearsCtrl,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Languages
        Text(l10n.profileLanguages, style: AppTypography.caption),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final lang in _tutorLanguages)
              _ToggleChip(
                label: lang,
                selected: _selectedLanguages.contains(lang),
                onTap: () => setState(() {
                  if (!_selectedLanguages.remove(lang)) {
                    _selectedLanguages.add(lang);
                  }
                }),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Credentials
        _Field(label: l10n.profileCredentials, controller: _credentialsCtrl),
        const SizedBox(height: AppSpacing.md),

        // Bio
        _Field(label: l10n.bio, controller: _bioCtrl, maxLines: 3),
        const SizedBox(height: AppSpacing.md),

        // Trial available toggle
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.profileTrialAvailable,
                style: AppTypography.body,
              ),
            ),
            Switch.adaptive(
              value: _trialAvailable,
              activeTrackColor: AppColors.primary,
              onChanged: (v) => setState(() => _trialAvailable = v),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Submit
        _saving
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : AppButton(
                label: widget.submitLabel ?? l10n.submitForReview,
                expanded: true,
                onPressed: _submit,
              ),
        if (widget.showGoBackButton) ...[
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: l10n.goBack,
            expanded: true,
            variant: AppButtonVariant.outlined,
            onPressed: () => context.canPop() ? context.pop() : context.go('/'),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
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
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.surfaceAlt : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: Border.all(
            color: selected ? AppColors.textPrimary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check, size: 14),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(label, style: AppTypography.small),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.caption),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: AppTypography.body,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ],
    );
  }
}
