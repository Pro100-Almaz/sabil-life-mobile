import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state/favorites_provider.dart';
import '../../core/theme/app_colors.dart';

/// Animated save toggle wired to [favoritesProvider].
class HeartButton extends ConsumerStatefulWidget {
  const HeartButton({super.key, required this.listingId, this.size = 24});

  final String listingId;
  final double size;

  @override
  ConsumerState<HeartButton> createState() => _HeartButtonState();
}

class _HeartButtonState extends ConsumerState<HeartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
    lowerBound: 0.7,
    upperBound: 1.0,
    value: 1.0,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    ref.read(favoritesProvider.notifier).toggle(widget.listingId);
    _controller
      ..value = _controller.lowerBound
      ..animateTo(_controller.upperBound, curve: Curves.elasticOut);
  }

  @override
  Widget build(BuildContext context) {
    final isSaved = ref.watch(favoritesProvider).contains(widget.listingId);

    return GestureDetector(
      onTap: _toggle,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: ScaleTransition(
          scale: _controller,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.favorite,
                size: widget.size,
                color: isSaved ? AppColors.primary : AppColors.overlayScrim,
              ),
              Icon(
                Icons.favorite_border,
                size: widget.size,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
