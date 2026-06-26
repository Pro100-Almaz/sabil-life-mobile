import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/state/auth_provider.dart';
import '../../core/state/provider_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/tutor.dart';
import '../../shared/widgets/app_button.dart';

/// Family-side composer for sending an inquiry to a specific tutor.
/// Reached from the tutor profile sheet's "Inquire" CTA after JIT auth.
class TutorInquiryComposerScreen extends ConsumerStatefulWidget {
  const TutorInquiryComposerScreen({
    super.key,
    required this.tutorId,
    this.tutor,
  });

  final String tutorId;

  /// Passed via `go_router` extra when navigating from the profile sheet;
  /// null on deep links, in which case we fall back to the tutor list.
  final Tutor? tutor;

  @override
  ConsumerState<TutorInquiryComposerScreen> createState() =>
      _TutorInquiryComposerScreenState();
}

class _TutorInquiryComposerScreenState
    extends ConsumerState<TutorInquiryComposerScreen> {
  late final TextEditingController _message;
  bool _sending = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _message = TextEditingController();
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final user = ref.read(authProvider).user;
    if (user == null) return;
    final message = _message.text.trim();
    if (message.isEmpty) return;
    setState(() {
      _sending = true;
      _errorMessage = null;
    });
    try {
      await ref
          .read(inquiryRepositoryProvider)
          .create(tutorId: widget.tutorId, message: message);
      ref.invalidate(myInquiriesProvider(user.id));
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.requestSent)));
      context.pop();
    } on StateError catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tutorName = widget.tutor?.name;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.inquiryComposerTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (tutorName != null && tutorName.isNotEmpty) ...[
                Text(tutorName, style: AppTypography.h2),
                const SizedBox(height: AppSpacing.xs),
              ],
              Text(l10n.inquiryComposerHint, style: AppTypography.caption),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: TextField(
                  controller: _message,
                  maxLines: null,
                  expands: true,
                  enabled: !_sending,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: l10n.inquiryComposerHint,
                  ),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _errorMessage!,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              _sending
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2.5,
                      ),
                    )
                  : AppButton(
                      label: l10n.send,
                      onPressed: _send,
                      expanded: true,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
