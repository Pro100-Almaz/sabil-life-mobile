import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/state/auth_provider.dart';
import '../../core/state/provider_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
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
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _message = TextEditingController(
      text:
          'Hi! I am interested in this listing for my child. '
          'Could you share availability?',
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
    setState(() {
      _sending = true;
      _errorMessage = null;
    });
    try {
      await ref
          .read(listingEnrollmentRepositoryProvider)
          .enroll(widget.listingId);
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
    final asyncListing = ref.watch(catalogDetailProvider(widget.listingId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.inquiryComposerTitle)),
      body: SafeArea(
        child: asyncListing.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.genericLoadError, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: () =>
                      ref.invalidate(catalogDetailProvider(widget.listingId)),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
          data: (listing) => Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(listing.title, style: AppTypography.h2),
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
      ),
    );
  }
}
