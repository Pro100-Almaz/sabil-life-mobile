import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sabil_life/core/l10n/app_localizations.dart';
import 'package:sabil_life/core/state/auth_provider.dart';
import 'package:sabil_life/core/state/provider_subscriptions_provider.dart';
import 'package:sabil_life/core/util/provider_event_location.dart';
import 'package:sabil_life/data/api/api_client.dart';
import 'package:sabil_life/data/api/provider_subscriptions.dart';
import 'package:sabil_life/data/api/push_notifications.dart';
import 'package:sabil_life/data/models/auth_user.dart';
import 'package:sabil_life/data/models/provider_subscription.dart';
import 'package:sabil_life/data/repositories/auth_repository.dart';
import 'package:sabil_life/data/repositories/provider_subscription_repository.dart';
import 'package:sabil_life/features/provider_subscriptions/followed_providers_screen.dart';
import 'package:sabil_life/features/provider_subscriptions/provider_follow_button.dart';

AuthUser user(
  String id, {
  UserRole role = UserRole.family,
  Set<String> roles = const {},
}) => AuthUser(
  id: id,
  email: '$id@example.com',
  fullName: id,
  role: role,
  isVerified: true,
  roles: roles,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(
    () => SharedPreferences.setMockInitialValues({
      'sabil.auth.token': 'session-token',
    }),
  );

  test(
    'HTTP follows load all pages, use public UUIDs, and scope count to caller',
    () async {
      final client = ApiClient();
      addTearDown(client.dispose);
      final requests = <RequestOptions>[];
      client.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) {
            requests.add(request);
            Object? data;
            var status = 200;
            if (request.path == '/provider/subscribers/count/') {
              data = {'count': 42};
            } else if (request.method == 'POST') {
              data = {'provider_id': 'public-uuid', 'display_name': 'Teacher'};
              // Both first creation (201) and repeated subscription (200) work.
              status = requests.where((r) => r.method == 'POST').length == 1
                  ? 201
                  : 200;
            } else if (request.method == 'DELETE') {
              status = 204;
            } else {
              final page = request.queryParameters['page'] as int;
              data = {
                'next': page == 1 ? 'https://api.example.com/?page=2' : null,
                'results': [
                  {
                    'provider_id': 'uuid-$page',
                    'display_name': 'Teacher $page',
                  },
                ],
              };
            }
            handler.resolve(
              Response(requestOptions: request, statusCode: status, data: data),
            );
          },
        ),
      );
      final repository = HttpProviderSubscriptionRepository(dio: client.dio);
      expect((await repository.mine()).map((s) => s.providerId), [
        'uuid-1',
        'uuid-2',
      ]);
      expect(
        (await repository.subscribe('public-uuid')).providerId,
        'public-uuid',
      );
      expect(
        (await repository.subscribe('public-uuid')).providerId,
        'public-uuid',
      );
      await repository.unsubscribe('public-uuid');
      expect(await repository.mySubscriberCount(), 42);
      expect(
        requests.every(
          (r) => r.headers['Authorization'] == 'Bearer session-token',
        ),
        isTrue,
      );
      expect(
        requests
            .where((r) => r.method == 'POST')
            .every(
              (r) =>
                  (r.data as Map).length == 1 &&
                  r.data['provider_id'] == 'public-uuid',
            ),
        isTrue,
      );
      expect(requests.last.queryParameters, isEmpty);
      expect(requests.last.data, isNull);
      expect(requests[4].path, '/provider-subscriptions/public-uuid/');
    },
  );

  for (final status in [404, 403, 500]) {
    test(
      'unsubscribe handles $status without hiding permission/server failures',
      () async {
        final dio = Dio();
        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (request, handler) {
              handler.reject(
                DioException(
                  requestOptions: request,
                  response: Response(
                    requestOptions: request,
                    statusCode: status,
                  ),
                ),
              );
            },
          ),
        );
        final future = HttpProviderSubscriptionRepository(
          dio: dio,
        ).unsubscribe('uuid');
        if (status == 404) {
          await future;
        } else {
          await expectLater(future, throwsA(isA<DioException>()));
        }
      },
    );
  }

  test(
    'repeated taps share pending state and account changes clear follows and count',
    () async {
      final auth = _Auth(user('family-a'));
      final repository = _Subscriptions();
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((_) => auth),
          providerSubscriptionRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      final listener = container.listen(followedProvidersProvider, (_, _) {});
      addTearDown(listener.close);
      expect(
        await container.read(followedProvidersProvider.future),
        hasLength(1),
      );
      final actions = container.read(providerFollowActionsProvider.notifier);
      repository.pending = Completer<FollowedProvider>();
      final first = actions.setFollowing('provider-b', following: true);
      await actions.setFollowing('provider-b', following: true);
      expect(repository.subscribeCalls, 1);
      expect(container.read(providerFollowActionsProvider), {'provider-b'});
      // Changing accounts while a mutation is pending cannot populate the new account.
      repository.items = [];
      auth.change(user('family-b'));
      expect(await container.read(followedProvidersProvider.future), isEmpty);
      repository.pending!.complete(
        const FollowedProvider(providerId: 'provider-b', displayName: 'B'),
      );
      await first;
      expect(await container.read(followedProvidersProvider.future), isEmpty);
      expect(container.read(providerFollowActionsProvider), isEmpty);
      expect(await container.read(mySubscriberCountProvider.future), 0);
      expect(repository.countCalls, 0);
      auth.change(user('provider-a', role: UserRole.tutor));
      expect(await container.read(mySubscriberCountProvider.future), 12);
      repository.count = 3;
      auth.change(user('provider-b', role: UserRole.masterclass));
      expect(await container.read(mySubscriberCountProvider.future), 3);
      expect(repository.countCalls, 2);
    },
  );

  testWidgets(
    'follow button subscribes, shows unsubscribe, and prevents self follows',
    (tester) async {
      final auth = _Auth(user('family', roles: {'FAMILY', 'TUTOR'}));
      final repository = _Subscriptions()..items = [];
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((_) => auth),
            providerSubscriptionRepositoryProvider.overrideWithValue(
              repository,
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Column(
                children: [
                  ProviderFollowButton(providerId: 'provider'),
                  ProviderFollowButton(providerId: 'family'),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Follow provider'), findsOneWidget);
      await tester.tap(find.text('Follow provider'));
      await tester.pumpAndSettle();
      expect(repository.subscribeCalls, 1);
      expect(find.text('Unfollow'), findsOneWidget);
      await tester.tap(find.text('Unfollow'));
      await tester.pumpAndSettle();
      expect(repository.unsubscribeCalls, 1);
      expect(find.text('Follow provider'), findsOneWidget);
    },
  );

  testWidgets('followed provider list supports removal and empty state', (
    tester,
  ) async {
    final repository = _Subscriptions();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((_) => _Auth(user('family'))),
          providerSubscriptionRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: FollowedProvidersScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Teacher'), findsOneWidget);
    await tester.tap(find.text('Unfollow'));
    await tester.pumpAndSettle();
    expect(find.text('Teacher'), findsNothing);
    expect(
      find.text('You are not following any providers yet.'),
      findsOneWidget,
    );
  });

  test(
    'event alert destination requires complete identifiers and encodes listing IDs',
    () {
      expect(
        providerEventLocation({'listing_id': 'listing', 'event_id': 'event'}),
        '/listing/listing/events',
      );
      expect(
        providerEventLocation({'listing_id': 'a/b', 'event_id': 'event'}),
        '/listing/a%2Fb/events',
      );
      expect(providerEventLocation({'listing_id': 'listing'}), isNull);
      expect(
        providerEventLocation({'listing_id': 3, 'event_id': 'event'}),
        isNull,
      );
    },
  );
}

class _Auth extends AuthNotifier {
  _Auth(AuthUser user) : super(MockAuthRepository(), push: _NoPush()) {
    change(user);
  }
  void change(AuthUser user) {
    state = AuthState.authenticated(user: user, token: 'token-${user.id}');
  }
}

class _NoPush implements PushNotifications {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Subscriptions implements ProviderSubscriptionRepository {
  List<FollowedProvider> items = [
    const FollowedProvider(providerId: 'provider', displayName: 'Teacher'),
  ];
  int subscribeCalls = 0;
  int unsubscribeCalls = 0;
  int countCalls = 0;
  int count = 12;
  Completer<FollowedProvider>? pending;
  @override
  Future<List<FollowedProvider>> mine() async => List.of(items);
  @override
  Future<FollowedProvider> subscribe(String providerId) async {
    subscribeCalls++;
    if (pending != null) return pending!.future;
    final item = FollowedProvider(
      providerId: providerId,
      displayName: 'Teacher',
    );
    items = [...items, item];
    return item;
  }

  @override
  Future<void> unsubscribe(String providerId) async {
    unsubscribeCalls++;
    items = items.where((i) => i.providerId != providerId).toList();
  }

  @override
  Future<int> mySubscriberCount() async {
    countCalls++;
    return count;
  }
}
