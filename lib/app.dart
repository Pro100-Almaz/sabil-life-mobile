import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sabil_life/core/state/provider_providers.dart';

import 'core/l10n/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/state/auth_provider.dart';
import 'core/state/locale_provider.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';
import 'data/api/api_client.dart';

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class SabilLifeApp extends ConsumerStatefulWidget {
  const SabilLifeApp({super.key});

  @override
  ConsumerState<SabilLifeApp> createState() => _SabilLifeAppState();
}

class _SabilLifeAppState extends ConsumerState<SabilLifeApp> {
  StreamSubscription<void>? _unauthorizedSub;
  StreamSubscription<RateLimitedEvent>? _rateLimitedSub;
  StreamSubscription<void>? _tapSub;

  @override
  void initState() {
    super.initState();
    // One-shot session restore from shared_preferences. The router waits on
    // an unknown -> {un,authenticated} transition by showing a tiny splash.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(authProvider.notifier).restore(),
    );
    // Log the user out whenever the API layer receives a 401.
    _unauthorizedSub = apiClient.onUnauthorized.listen((_) {
      ref.read(authProvider.notifier).logout();
    });
    // Show a SnackBar whenever the API layer receives a 429.
    _rateLimitedSub = apiClient.onRateLimited.listen((_) {
      final l10n = AppLocalizations.of(
        scaffoldMessengerKey.currentContext ?? (throw StateError('no context')),
      );
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(
            l10n?.rateLimited ?? 'Rate limited. Please try again shortly.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
    _tapSub = ref.read(pushNotificationsProvider).onNotificationTap.listen((
      data,
    ) {
      final router = ref.read(routerProvider);
      if (data['status'] == 'APPROVED' || data['status'] == 'REJECTED') {
        router.go('/provider/tutor/settings');
      } else {
        router.go('/notifications');
      }
    });
  }

  @override
  void dispose() {
    _unauthorizedSub?.cancel();
    _rateLimitedSub?.cancel();
    _tapSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final authStatus = ref.watch(authProvider.select((s) => s.status));

    if (authStatus == AuthStatus.unknown) {
      // Pre-router splash so role-based redirects see settled auth state.
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        scaffoldMessengerKey: scaffoldMessengerKey,
        home: const _SplashScreen(),
      );
    }

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      scaffoldMessengerKey: scaffoldMessengerKey,
      routerConfig: ref.watch(routerProvider),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2.5,
              ),
            ),
            const SizedBox(height: 24),
            Text('Sabil Life', style: AppTypography.h3),
          ],
        ),
      ),
    );
  }
}
