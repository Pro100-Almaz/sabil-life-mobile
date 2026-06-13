import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/listing.dart';
import '../../features/category/category_list_screen.dart';
import '../../features/detail/listing_detail_screen.dart';
import '../../features/favorites/favorites_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/map/map_screen.dart';
import '../../features/masterclasses/masterclasses_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/shell/shell_screen.dart';
import '../../features/tutoring/tutoring_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          ShellScreen(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/map',
              builder: (context, state) => MapScreen(
                focusListingId: state.uri.queryParameters['listing'],
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/favorites',
              builder: (context, state) => const FavoritesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/tutoring',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const TutoringScreen(),
    ),
    GoRoute(
      path: '/masterclasses',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const MasterclassesScreen(),
    ),
    GoRoute(
      path: '/category/:type',
      parentNavigatorKey: _rootNavigatorKey,
      // Tutoring and masterclasses have dedicated experiences.
      redirect: (context, state) => switch (state.pathParameters['type']) {
        'tutoring' => '/tutoring',
        'masterclasses' => '/masterclasses',
        _ => null,
      },
      builder: (context, state) {
        final raw = state.pathParameters['type'] ?? '';
        final category = CategoryType.values
            .where((c) => c.name == raw)
            .firstOrNull;
        return CategoryListScreen(category: category);
      },
    ),
    GoRoute(
      path: '/listing/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) =>
          ListingDetailScreen(listingId: state.pathParameters['id'] ?? ''),
    ),
  ],
);
