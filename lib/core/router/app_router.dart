import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/listing.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/category/category_list_screen.dart';
import '../../features/detail/listing_detail_screen.dart';
import '../../features/family/inquiry_composer_screen.dart';
import '../../features/family/my_requests_screen.dart';
import '../../features/family/suggestion_screen.dart';
import '../../features/favorites/favorites_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/map/map_screen.dart';
import '../../features/masterclasses/masterclasses_screen.dart';
import '../../features/provider/dashboard_screen.dart';
import '../../features/provider/earnings_screen.dart';
import '../../features/provider/inquiries_screen.dart';
import '../../features/provider/listing_editor_screen.dart';
import '../../features/provider/my_listings_screen.dart';
import '../../features/provider/provider_settings_screen.dart';
import '../../features/provider/provider_shell.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/shell/shell_screen.dart';
import '../../features/tutoring/tutoring_screen.dart';
import '../state/auth_provider.dart';
import 'router_refresh.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _familyShellKey = GlobalKey<NavigatorState>();
final _providerShellKey = GlobalKey<NavigatorState>();

bool _isProviderArea(String location) => location.startsWith('/provider');
bool _isAuthArea(String location) =>
    location == '/login' || location == '/register';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = RouterRefreshListenable();
  ref.listen<AuthState>(authProvider, (prev, next) => refresh.notify());
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final location = state.matchedLocation;

      // Don't redirect while a session restore / login is in flight.
      if (auth.status == AuthStatus.unknown ||
          auth.status == AuthStatus.authenticating) {
        return null;
      }

      // Provider tried to visit /provider/... → must be signed in as provider.
      if (_isProviderArea(location)) {
        if (!auth.isAuthenticated) return '/login';
        if (!auth.isProvider) return '/';
      }

      // Logged-in provider on auth pages → bounce to their dashboard.
      if (auth.isAuthenticated && _isAuthArea(location)) {
        return auth.isProvider ? '/provider' : '/';
      }

      // Logged-in provider hitting the family root → land in provider area
      // unless they explicitly opted in via the "Browse as family" link
      // (which uses query ?as=family).
      if (auth.isAuthenticated &&
          auth.isProvider &&
          location == '/' &&
          state.uri.queryParameters['as'] != 'family') {
        return '/provider';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RegisterScreen(),
      ),

      // ── Family shell ─────────────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ShellScreen(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _familyShellKey,
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
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
      GoRoute(
        path: '/inquiry/:listingId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => InquiryComposerScreen(
          listingId: state.pathParameters['listingId'] ?? '',
          tutorIdHint: state.uri.queryParameters['tutor'],
        ),
      ),
      GoRoute(
        path: '/my-requests',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MyRequestsScreen(),
      ),
      GoRoute(
        path: '/suggest',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SuggestionScreen(),
      ),

      // ── Provider shell ───────────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ProviderShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _providerShellKey,
            routes: [
              GoRoute(
                path: '/provider',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/provider/listings',
                builder: (context, state) => const MyListingsScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) =>
                        const ListingEditorScreen(listingId: null),
                  ),
                  GoRoute(
                    path: 'edit/:id',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => ListingEditorScreen(
                      listingId: state.pathParameters['id'],
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/provider/inquiries',
                builder: (context, state) => const InquiriesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/provider/earnings',
                builder: (context, state) => const EarningsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/provider/settings',
                builder: (context, state) => const ProviderSettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
