import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/state/auth_provider.dart';
import '../../core/state/favorites_provider.dart';
import '../../core/state/masterclass_provider.dart';
import '../../core/state/provider_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/util/distance.dart';
import '../../core/util/tutor_label.dart';
import '../../data/mock/mock_masterclasses.dart';
import '../../data/mock/mock_tutors.dart';
import '../../data/models/listing.dart';
import '../../data/models/masterclass_info.dart';
import '../../data/models/review.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../data/repositories/review_repository.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/star_rating.dart';
import '../family/widgets/request_cta.dart';
import '../tutoring/widgets/tutor_profile_sheet.dart';
import 'widgets/image_carousel.dart';
import 'widgets/info_tile.dart';
import 'widgets/rating_row.dart';

class ListingDetailScreen extends ConsumerWidget {
  const ListingDetailScreen({super.key, required this.listingId});

  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncListing = ref.watch(catalogDetailProvider(listingId));

    return asyncListing.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.genericLoadError, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () =>
                    ref.invalidate(catalogDetailProvider(listingId)),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
      data: (listing) => _DetailBody(listing: listing),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isSaved = ref.watch(favoritesProvider).contains(listing.id);
    final asyncReviews = ref.watch(listingReviewsProvider(listing.id));
    final reviews = asyncReviews.valueOrNull ?? const <Review>[];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 300,
            backgroundColor: AppColors.surface,
            leading: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: _CircleIconButton(
                icon: Icons.arrow_back,
                onTap: () => context.pop(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: ImageCarousel(
                imageUrls: listing.imageUrls,
                listingId: listing.id,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(listing.title, style: AppTypography.display),
                  const SizedBox(height: AppSpacing.xs),
                  Text(listing.subtitle, style: AppTypography.caption),
                  const SizedBox(height: AppSpacing.md),
                  RatingRow(
                    rating: listing.rating,
                    reviewCount: listing.reviewCount,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(
                        Icons.place_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(listing.neighborhood, style: AppTypography.caption),
                      Text(' · ', style: AppTypography.caption),
                      Text(
                        l10n.distanceAway(listing.distanceFromHomeLabel),
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    listing.priceFromQar == 0
                        ? l10n.free
                        : l10n.fromPrice('${listing.priceFromQar}'),
                    style: AppTypography.h3,
                  ),
                  if (listing.category == CategoryType.masterclasses &&
                      mockMasterclassInfo[listing.id] != null) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                      child: Divider(),
                    ),
                    _SessionPicker(
                      listingId: listing.id,
                      info: mockMasterclassInfo[listing.id]!,
                    ),
                  ],
                  if (listing.category == CategoryType.tutoring &&
                      tutorsForListing(listing.id).isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                      child: Divider(),
                    ),
                    _TutorsRail(listingId: listing.id),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                    child: Divider(),
                  ),
                  Text(l10n.highlights, style: AppTypography.h2),
                  const SizedBox(height: AppSpacing.md),
                  for (final highlight in listing.highlights)
                    InfoTile(text: highlight),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                    child: Divider(),
                  ),
                  Text(l10n.about, style: AppTypography.h2),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    listing.description,
                    style: AppTypography.body.copyWith(height: 1.5),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                    child: Divider(),
                  ),
                  Text(l10n.details, style: AppTypography.h2),
                  const SizedBox(height: AppSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    child: SizedBox(
                      height: 180,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(listing.lat, listing.lng),
                          initialZoom: 14,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.none,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'io.sabil.sabil_life',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(listing.lat, listing.lng),
                                width: 36,
                                height: 36,
                                child: const Icon(
                                  Icons.place,
                                  size: 36,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: l10n.viewOnMap,
                    variant: AppButtonVariant.outlined,
                    icon: Icons.map_outlined,
                    expanded: true,
                    onPressed: () => context.go('/map?listing=${listing.id}'),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                    child: Divider(),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 18, color: AppColors.star),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '${listing.rating.toStringAsFixed(1)} · '
                        '${l10n.reviews(listing.reviewCount)}',
                        style: AppTypography.h2.copyWith(fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (asyncReviews.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  else
                    for (final review in reviews) ...[
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.surfaceAlt,
                            child: Text(
                              review.author.characters.first,
                              style: AppTypography.label,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(review.author, style: AppTypography.label),
                              Text(
                                l10n.monthsAgo(review.monthsAgo),
                                style: AppTypography.small,
                              ),
                            ],
                          ),
                          const Spacer(),
                          StarRating(rating: review.rating.toDouble()),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        review.text,
                        style: AppTypography.body.copyWith(height: 1.4),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  _WriteReviewCta(listingId: listing.id),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.md,
        ),
        child: SafeArea(
          child: Row(
            children: [
              if (listing.category == CategoryType.tutoring ||
                  listing.category == CategoryType.masterclasses)
                Expanded(child: RequestCta(listingId: listing.id))
              else
                Expanded(
                  child: AppButton(
                    label: isSaved ? l10n.saved : l10n.save,
                    icon: isSaved ? Icons.favorite : Icons.favorite_border,
                    onPressed: () async {
                      try {
                        await ref
                            .read(favoritesProvider.notifier)
                            .toggle(listing.id);
                      } on FavoritesException catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.message),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton(
                  label: l10n.share,
                  variant: AppButtonVariant.outlined,
                  icon: Icons.ios_share,
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: 'sabil.life/listing/${listing.id}'),
                    );
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(l10n.linkCopied)));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionPicker extends ConsumerWidget {
  const _SessionPicker({required this.listingId, required this.info});

  final String listingId;
  final MasterclassInfo info;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    final sessions =
        info.sessions.where((s) => s.start.isAfter(DateTime.now())).toList()
          ..sort((a, b) => a.start.compareTo(b.start));
    if (sessions.isEmpty) return const SizedBox.shrink();

    final selectedIndex = (ref.watch(selectedSessionProvider)[listingId] ?? 0)
        .clamp(0, sessions.length - 1);
    final selected = sessions[selectedIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.pickDate, style: AppTypography.h2),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${l10n.durationMinutes(info.durationMin)} · '
          '${info.parentAndChild ? l10n.withParent : l10n.dropOff} · '
          '${info.sessionsCount > 1 ? l10n.seriesCount(info.sessionsCount) : l10n.oneOffEvent}',
          style: AppTypography.caption,
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (var i = 0; i < sessions.length; i++)
              GestureDetector(
                onTap: () => ref
                    .read(selectedSessionProvider.notifier)
                    .select(listingId, i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: i == selectedIndex
                        ? AppColors.surfaceAlt
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.button),
                    border: Border.all(
                      color: i == selectedIndex
                          ? AppColors.textPrimary
                          : AppColors.border,
                      width: i == selectedIndex ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    '${DateFormat('EEE, d MMM', locale).format(sessions[i].start)} · '
                    '${DateFormat('HH:mm', locale).format(sessions[i].start)}',
                    style: AppTypography.label,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.seatsLeft(selected.seatsLeft),
          style: AppTypography.label.copyWith(
            color: selected.seatsLeft <= 5
                ? AppColors.primary
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _TutorsRail extends StatelessWidget {
  const _TutorsRail({required this.listingId});

  final String listingId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tutors = tutorsForListing(listingId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.ourTutors, style: AppTypography.h2),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: tutors.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final tutor = tutors[index];
              return GestureDetector(
                onTap: () => showTutorProfileSheet(context, tutor),
                child: Container(
                  width: 130,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: tutor.avatarUrl,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 48,
                            height: 48,
                            color: AppColors.surfaceAlt,
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 48,
                            height: 48,
                            color: AppColors.surfaceAlt,
                            child: const Icon(
                              Icons.person_outline,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        tutor.name,
                        style: AppTypography.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        tutor.subjects.first.label(l10n),
                        style: AppTypography.small,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Text(
                        l10n.perHour('${tutor.pricePerHourQar}'),
                        style: AppTypography.small.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WriteReviewCta extends ConsumerStatefulWidget {
  const _WriteReviewCta({required this.listingId});

  final String listingId;

  @override
  ConsumerState<_WriteReviewCta> createState() => _WriteReviewCtaState();
}

class _WriteReviewCtaState extends ConsumerState<_WriteReviewCta> {
  int _rating = 5;
  late final TextEditingController _text;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _text = TextEditingController();
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_text.text.trim().isEmpty) return;
    setState(() => _submitting = true);
    try {
      await ref
          .read(reviewRepositoryProvider)
          .create(
            listingId: widget.listingId,
            rating: _rating,
            text: _text.text.trim(),
          );
      ref.invalidate(listingReviewsProvider(widget.listingId));
      ref.invalidate(catalogDetailProvider(widget.listingId));
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review submitted'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ReviewException catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showDialog(BuildContext ctx) {
    showModalBottomSheet<void>(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.xxl,
            right: AppSpacing.xxl,
            top: AppSpacing.xl,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Write a review', style: AppTypography.h2),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final star = i + 1;
                  return GestureDetector(
                    onTap: () {
                      setModalState(() => _rating = star);
                      setState(() => _rating = star);
                    },
                    child: Icon(
                      star <= _rating ? Icons.star : Icons.star_border,
                      color: AppColors.star,
                      size: 32,
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _text,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Share your experience…',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: _submitting ? 'Submitting…' : 'Submit',
                expanded: true,
                onPressed: _submitting ? () {} : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    // Providers don't write reviews; anonymous users redirect to login.
    if (auth.isProvider) return const SizedBox.shrink();

    if (!auth.isAuthenticated) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: AppButton(
          label: 'Write a review',
          variant: AppButtonVariant.outlined,
          icon: Icons.rate_review_outlined,
          expanded: true,
          onPressed: () => context.push('/login'),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: AppButton(
        label: 'Write a review',
        variant: AppButtonVariant.outlined,
        icon: Icons.rate_review_outlined,
        expanded: true,
        onPressed: () => _showDialog(context),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: AppShadow.soft,
        ),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }
}
