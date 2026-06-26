import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/state/auth_provider.dart';
import '../../../core/state/provider_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/auth_user.dart';
import '../../../data/models/listing_enroll.dart';
import '../../../shared/widgets/app_button.dart';
import '../../auth/widgets/auth_sheet.dart';

/// Family CTA for masterclass listings. One tap (after just-in-time auth)
/// creates a [ListingEnrollment] against the backend; once enrolled it flips to
/// an "Enrolled" state that lets the family cancel. Providers don't see it.
class ListingEnrollmentCta extends ConsumerStatefulWidget {
  const ListingEnrollmentCta({
    super.key,
    required this.listingId,
    this.expanded = true,
  });

  final String listingId;
  final bool expanded;

  @override
  ConsumerState<ListingEnrollmentCta> createState() =>
      _ListingEnrollmentCtaState();
}

class _ListingEnrollmentCtaState extends ConsumerState<ListingEnrollmentCta> {
  bool _busy = false;

  Future<void> _enroll() async {
    final ok = await presentAuthSheet(context, ref);
    if (!ok || !mounted) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      await ref
          .read(listingEnrollmentRepositoryProvider)
          .enroll(widget.listingId);
      ref.invalidate(myListingEnrollmentsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.enrollmentSubmitted),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      // Refresh state in case the failure was "already enrolled".
      ref.invalidate(myListingEnrollmentsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_message(e)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel(ListingEnrollment existing) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.cancelListingEnrollmentTitle),
        content: Text(l10n.cancelListingEnrollmentMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.keepEnrollment),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l10n.cancelRequestConfirm,
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(listingEnrollmentRepositoryProvider)
          .cancelEnrollment(existing.id);
      ref.invalidate(myListingEnrollmentsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.enrollmentCancelled),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_message(e)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _message(Object e) => e is StateError ? e.message : e.toString();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);

    // Providers don't enroll in listings via this CTA.
    if (auth.user?.role == UserRole.tutor ||
        auth.user?.role == UserRole.masterclass) {
      return const SizedBox.shrink();
    }

    if (_busy) {
      return AppButton(
        label: l10n.loading,
        expanded: widget.expanded,
        onPressed: () {},
      );
    }

    // Logged-out families get a plain Enroll button (auth is requested on tap).
    if (!auth.isAuthenticated) {
      return AppButton(
        label: l10n.enroll,
        icon: Icons.send_outlined,
        expanded: widget.expanded,
        onPressed: _enroll,
      );
    }

    final enrollmentsAsync = ref.watch(myListingEnrollmentsProvider);

    // Until the first load resolves (and the cache is warm), show a neutral
    // loading button instead of flashing "Enroll" before we know the state.
    if (enrollmentsAsync.isLoading && !enrollmentsAsync.hasValue) {
      return AppButton(
        label: l10n.loading,
        expanded: widget.expanded,
        onPressed: () {},
      );
    }

    final existing = enrollmentsAsync.valueOrNull
        ?.where((r) => r.listing.id == widget.listingId)
        .firstOrNull;

    if (existing != null) {
      return AppButton(
        label: l10n.enrolled,
        icon: Icons.check,
        variant: AppButtonVariant.outlined,
        expanded: widget.expanded,
        onPressed: () => _cancel(existing),
      );
    }

    return AppButton(
      label: l10n.enroll,
      icon: Icons.send_outlined,
      expanded: widget.expanded,
      onPressed: _enroll,
    );
  }
}
