import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/listing.dart';
import '../../data/models/tutor.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/category/category_list_screen.dart';
import '../../features/detail/listing_detail_screen.dart';
import '../../features/family/listing_client_composer_screen.dart';
import '../../features/family/my_enrollments_screen.dart';
import '../../features/family/suggestion_screen.dart';
import '../../features/family/tutor_inquiry_composer_screen.dart';
import '../../features/favorites/favorites_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/map/map_screen.dart';
import '../../features/provider/dashboard_screen.dart';
import '../../features/provider/earnings_screen.dart';
import '../../features/provider/inquiries_screen.dart';
import '../../features/provider/listing_clients_screen.dart';
import '../../features/provider/listing_editor_screen.dart';
import '../../features/provider/masterclass_gate_screen.dart';
import '../../features/provider/my_listings_screen.dart';
import '../../features/provider/provider_settings_screen.dart';
import '../../features/provider/provider_shell.dart';
import '../../features/provider/tutor_gate_screen.dart';
import '../../features/provider/tutor_profile_edit_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/shell/shell_screen.dart';
import '../../features/tutoring/tutoring_screen.dart';
import '../state/auth_provider.dart';
import 'router_refresh.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _familyShellKey = GlobalKey<NavigatorState>();
final _tutorShellKey = GlobalKey<NavigatorState>();
final _masterclassShellKey = GlobalKey<NavigatorState>();

/// Builds a provider shell route tree for [interface]. Each provider role gets
/// its own tree (`/provider/tutor/*`, `/provider/masterclass/*`) so the two
/// interfaces keep separate navigation state and can diverge later.
StatefulShellRoute _providerShellRoute({
  required ActiveInterface interface,
  required GlobalKey<NavigatorState> rootBranchKey,
}) {
  final base = interface.basePath;

  final dashboardBranch = StatefulShellBranch(
    navigatorKey: rootBranchKey,
    routes: [
      GoRoute(
        path: base,
        builder: (context, state) => DashboardScreen(interface: interface),
      ),
    ],
  );

  // Listings are tutor-less: only the masterclass interface manages listings.
  final listingsBranch = StatefulShellBranch(
    routes: [
      GoRoute(
        path: '$base/listings',
        builder: (context, state) => MyListingsScreen(interface: interface),
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
              initialListing: state.extra is Listing
                  ? state.extra as Listing
                  : null,
            ),
          ),
          GoRoute(
            path: 'clients/:id',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => ListingClientsScreen(
              listingId: state.pathParameters['id'] ?? '',
              listingTitle: state.extra is Listing
                  ? (state.extra as Listing).title
                  : null,
            ),
          ),
        ],
      ),
    ],
  );

  // Inquiries are only surfaced on the tutor interface.
  final inquiriesBranch = StatefulShellBranch(
    routes: [
      GoRoute(
        path: '$base/inquiries',
        builder: (context, state) => const InquiriesScreen(),
      ),
    ],
  );

  final earningsBranch = StatefulShellBranch(
    routes: [
      GoRoute(
        path: '$base/earnings',
        builder: (context, state) => const EarningsScreen(),
      ),
    ],
  );

  final settingsBranch = StatefulShellBranch(
    routes: [
      GoRoute(
        path: '$base/settings',
        builder: (context, state) =>
            ProviderSettingsScreen(interface: interface),
        routes: [
          GoRoute(
            path: 'edit-profile',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => const TutorProfileEditScreen(),
          ),
        ],
      ),
    ],
  );

  // Branch order must match the nav items in ProviderShell.
  final branches = <StatefulShellBranch>[
    dashboardBranch,
    if (interface == ActiveInterface.masterclass) listingsBranch,
    if (interface == ActiveInterface.tutor) inquiriesBranch,
    earningsBranch,
    settingsBranch,
  ];

  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) =>
        ProviderShell(navigationShell: navigationShell, interface: interface),
    branches: branches,
  );
}

bool _isProviderArea(String location) => location.startsWith('/provider');
bool _isAuthArea(String location) =>
    location == '/login' || location == '/register';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = RouterRefreshListenable();
  ref.listen<AuthState>(authProvider, (prev, next) => refresh.notify());
  ref.listen<ActiveInterface>(activeInterfaceProvider, (prev, next) {
    refresh.notify();
  });
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final activeInterface = ref.read(activeInterfaceProvider);
      final location = state.matchedLocation;

      if (auth.status == AuthStatus.unknown ||
          auth.status == AuthStatus.authenticating) {
        return null;
      }

      if (_isProviderArea(location)) {
        if (!auth.isAuthenticated) return '/login';
        if (!activeInterface.isProvider) return '/';
        // Keep the location on the active interface's own tree.
        if (!location.startsWith(activeInterface.basePath)) {
          return activeInterface.basePath;
        }
      }

      if (auth.isAuthenticated && _isAuthArea(location)) {
        return '/';
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
        path: '/category/:type',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final raw = state.pathParameters['type'] ?? '';
          final category = CategoryType.values
              .where((c) => c.name == raw)
              .firstOrNull;
          if (category == CategoryType.tutoring) {
            return const TutoringScreen();
          }
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
        path: '/inquire/tutor/:tutorId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => TutorInquiryComposerScreen(
          tutorId: state.pathParameters['tutorId'] ?? '',
          tutor: state.extra is Tutor ? state.extra as Tutor : null,
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
      GoRoute(
        path: '/switch-to-tutor',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TutorGateScreen(),
      ),
      GoRoute(
        path: '/switch-to-masterclass',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MasterclassGateScreen(),
      ),
      GoRoute(
        path: '/tutor-profile-edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TutorProfileEditScreen(),
      ),

      // ── Provider shells (one tree per interface) ─────────────────────────
      _providerShellRoute(
        interface: ActiveInterface.tutor,
        rootBranchKey: _tutorShellKey,
      ),
      _providerShellRoute(
        interface: ActiveInterface.masterclass,
        rootBranchKey: _masterclassShellKey,
      ),
    ],
  );
});
