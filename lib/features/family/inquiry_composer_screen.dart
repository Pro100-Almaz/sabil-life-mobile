import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/state/auth_provider.dart';
import '../../core/state/provider_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/mock/mock_listings.dart';
import '../../shared/widgets/app_button.dart';

class InquiryComposerScreen extends ConsumerStatefulWidget {
  const InquiryComposerScreen({
    super.key,
    required this.listingId,
    this.tutorIdHint,
  });

  final String listingId;
  final String? tutorIdHint;

  @override
  ConsumerState<InquiryComposerScreen> createState() =>
      _InquiryComposerScreenState();
}

class _InquiryComposerScreenState extends ConsumerState<InquiryComposerScreen> {
  late final TextEditingController _message;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    final listing = listingById(widget.listingId);
    _message = TextEditingController(
      text:
          'Hi! Interested in ${listing?.title ?? 'this listing'} for my '
          'child. Could you share availability?',
    );
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final auth = ref.read(authProvider);
    final user = auth.user;
    if (user == null) return;
    setState(() => _sending = true);
    try {
      await ref
          .read(inquiryRepositoryProvider)
          .create(
            listingId: widget.listingId,
            familyId: user.id,
            familyName: user.fullName,
            familyEmail: user.email,
            message: _message.text,
            tutorIdHint: widget.tutorIdHint,
          );
      // Refresh both sides of the request so any open list updates.
      ref.invalidate(myInquiriesProvider(user.id));
      final listing = listingById(widget.listingId);
      if (listing?.ownerId != null) {
        ref.invalidate(incomingInquiriesProvider(listing!.ownerId!));
      }
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.requestSent)));
      context.pop();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final listing = listingById(widget.listingId);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.inquiryComposerTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (listing != null) Text(listing.title, style: AppTypography.h2),
              const SizedBox(height: AppSpacing.xs),
              Text(l10n.inquiryComposerHint, style: AppTypography.caption),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: TextField(
                  controller: _message,
                  maxLines: null,
                  expands: true,
                  enabled: !_sending,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(hintText: l10n.send),
                ),
              ),
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
