import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// A coral [RefreshIndicator] used for pull-to-refresh across the app. The
/// [child] must contain a scrollable that reaches the top edge; wrap empty /
/// error states in a [RefreshableMessage] so the pull gesture still fires when
/// there is nothing to scroll.
class AppRefreshIndicator extends StatelessWidget {
  const AppRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      child: child,
    );
  }
}

/// Centres [child] inside an always-scrollable viewport so a parent
/// [AppRefreshIndicator] responds to a pull even on loading / empty / error
/// states that have no scrollable content of their own.
class RefreshableMessage extends StatelessWidget {
  const RefreshableMessage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(child: child),
        ),
      ),
    );
  }
}
