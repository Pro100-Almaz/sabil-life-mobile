import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/heart_button.dart';
import '../../../data/models/listing.dart';

/// Swipeable PageView of listing photos with page dots and a heart overlay.
class ImageCarousel extends StatefulWidget {
  const ImageCarousel({
    super.key,
    required this.imageUrls,
    required this.listingId,
  });

  final List<String> imageUrls;
  final String listingId;

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _page = 0;

  List<String> get _validImageUrls =>
      widget.imageUrls.where((url) => url.trim().isNotEmpty).toList();

  @override
  Widget build(BuildContext context) {
    final imageUrls = _validImageUrls;

    if (imageUrls.isEmpty) {
      return AspectRatio(
        aspectRatio: 4 / 3,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(kListingFallbackAsset, fit: BoxFit.cover),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: SafeArea(
                child: HeartButton(listingId: widget.listingId, size: 28),
              ),
            ),
          ],
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: widget.imageUrls.length,
            onPageChanged: (page) => setState(() => _page = page),
            itemBuilder: (context, index) => CachedNetworkImage(
              imageUrl: widget.imageUrls[index],
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Container(color: AppColors.surfaceAlt),
              errorWidget: (context, url, error) => Container(
                color: AppColors.surfaceAlt,
                child: const Icon(
                  Icons.photo_outlined,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: SafeArea(
              child: HeartButton(listingId: widget.listingId, size: 28),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < widget.imageUrls.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _page ? 8 : 6,
                    height: i == _page ? 8 : 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _page
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
