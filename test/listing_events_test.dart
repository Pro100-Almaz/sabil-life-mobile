import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sabil_life/core/l10n/app_localizations.dart';
import 'package:sabil_life/core/state/event_providers.dart';
import 'package:sabil_life/core/state/provider_providers.dart';
import 'package:sabil_life/data/api/push_notifications.dart';
import 'package:sabil_life/data/api/api_client.dart';
import 'package:sabil_life/data/api/events.dart';
import 'package:sabil_life/data/api/listing_parser.dart';
import 'package:sabil_life/data/models/listing_event.dart';
import 'package:sabil_life/data/repositories/event_repository.dart';
import 'package:sabil_life/features/events/event_editor_screen.dart';
import 'package:sabil_life/features/events/listing_events_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> eventJson(
  String id, {
  String published = '2026-11-09T10:00:00Z',
}) => {
  'id': id,
  'listing': 'listing-1',
  'title': 'Event $id',
  'description': 'Meet the teachers',
  'starts_at': '2026-12-12T09:00:00+03:00',
  'ends_at': null,
  'location': '',
  'registration_url': '',
  'published_at': published,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'embedded preview selects two latest publications independently of start ordering',
    () {
      final listing = ListingParser.fromDetail({
        'id': 'listing-1',
        'events': [
          eventJson('a'),
          eventJson('b', published: '2026-11-08T10:00:00Z'),
          eventJson('c', published: '2026-11-10T10:00:00Z'),
        ],
      });
      expect(latestListingEvents(listing.events).map((e) => e.id), ['c', 'a']);
      expect(
        listing.events.first.startsAt.toUtc(),
        DateTime.utc(2026, 12, 12, 6),
      );
      expect(listing.copyWith(title: 'Changed').events, hasLength(3));
      expect(ListingParser.fromDetail({'id': 'empty'}).events, isEmpty);
    },
  );

  test(
    'HTTP integration scopes endpoints, paginates, and omits stale public authentication',
    () async {
      SharedPreferences.setMockInitialValues({
        'sabil.auth.token': 'expired-token',
      });
      final client = ApiClient();
      addTearDown(client.dispose);
      final requests = <RequestOptions>[];
      client.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) {
            requests.add(request);
            handler.resolve(
              Response(
                requestOptions: request,
                statusCode: request.method == 'POST' ? 201 : 200,
                data: request.method == 'POST'
                    ? eventJson('created')
                    : {
                        'count': 21,
                        'next': request.queryParameters['page'] == 1
                            ? 'https://example.com/?page=2'
                            : null,
                        'results': [
                          eventJson('page-${request.queryParameters['page']}'),
                        ],
                      },
              ),
            );
          },
        ),
      );
      final repo = HttpEventRepository(dio: client.dio);
      final first = await repo.forListing('listing-1');
      final second = await repo.forListing('listing-1', page: 2);
      expect(first.hasNext, isTrue);
      expect(second.hasNext, isFalse);
      expect(requests[0].path, '/listings/listing-1/events/');
      expect(requests[1].queryParameters['page'], 2);
      expect(requests[0].headers.containsKey('Authorization'), isFalse);
      await repo.forListing('listing-1', owned: true);
      expect(requests[2].path, '/provider/listings/listing-1/events/');
      expect(requests[2].headers['Authorization'], 'Bearer expired-token');
      final created = await repo.publish('listing-1', {
        'title': 'School day',
        'starts_at': '2026-12-12T06:00:00Z',
        'ends_at': null,
      });
      expect(created.id, 'created');
      expect(requests.last.method, 'POST');
      expect(requests.last.path, '/provider/listings/listing-1/events/');
      expect(requests.last.data.containsKey('listing'), isFalse);
    },
  );

  testWidgets(
    'all events page loads the next page and preserves existing events',
    (tester) async {
      final repository = _Events();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            eventRepositoryProvider.overrideWithValue(repository),
            pushNotificationsProvider.overrideWithValue(_NoPush()),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ListingEventsScreen(listingId: 'listing-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Event page-1'), findsOneWidget);
      await tester.tap(find.text('Load more'));
      await tester.pumpAndSettle();
      expect(repository.pages, [1, 2]);
      expect(find.text('Event page-1'), findsOneWidget);
      expect(find.text('Event page-2'), findsOneWidget);
      expect(find.text('Load more'), findsNothing);
    },
  );

  testWidgets(
    'unfinished event form is restored and invalid title prevents publishing',
    (tester) async {
      final repository = _Events();
      Widget app() => ProviderScope(
        overrides: [
          eventRepositoryProvider.overrideWithValue(repository),
          pushNotificationsProvider.overrideWithValue(_NoPush()),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: EventEditorScreen(listingId: 'listing-1'),
        ),
      );
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField).first,
        'Saved open day',
      );
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(find.text('Saved open day'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).first, '   ');
      await tester.ensureVisible(find.text('Publish event'));
      await tester.tap(find.text('Publish event'));
      await tester.pumpAndSettle();
      expect(repository.published, isFalse);
      await tester.ensureVisible(find.byType(TextFormField).first);
      expect(find.text('This field is required.'), findsWidgets);
    },
  );

  testWidgets(
    'successful publication closes the form and removes its saved draft',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'event.draft.null.listing-1': jsonEncode({
          'title': 'Open day',
          'starts_at': '2026-12-12T09:00:00+03:00',
        }),
      });
      final repository = _Events();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            eventRepositoryProvider.overrideWithValue(repository),
            pushNotificationsProvider.overrideWithValue(_NoPush()),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          const EventEditorScreen(listingId: 'listing-1'),
                    ),
                  ),
                  child: const Text('Open form'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open form'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Publish event'));
      await tester.tap(find.text('Publish event'));
      await tester.pumpAndSettle();
      expect(repository.publishCalls, 1);
      expect(find.byType(EventEditorScreen), findsNothing);
      expect(find.text('Event published.'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('event.draft.null.listing-1'), isNull);
    },
  );

  for (final status in [400, 401, 403, 404, 0]) {
    testWidgets(
      'publish handles status $status and prevents repeated submissions',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'event.draft.null.listing-1': jsonEncode({
            'title': 'Open day',
            'starts_at': '2026-12-12T09:00:00+03:00',
          }),
        });
        final repository = _Events()..pending = Completer<ListingEvent>();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              eventRepositoryProvider.overrideWithValue(repository),
              pushNotificationsProvider.overrideWithValue(_NoPush()),
            ],
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: EventEditorScreen(listingId: 'listing-1'),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Publish event'));
        await tester.tap(find.text('Publish event'));
        await tester.pump();
        await tester.pump();
        expect(repository.publishCalls, 1);
        expect(
          tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
          isNull,
        );
        expect(repository.fields!['starts_at'], '2026-12-12T06:00:00.000Z');
        final request = RequestOptions(
          path: '/provider/listings/listing-1/events/',
        );
        repository.pending!.completeError(
          DioException(
            requestOptions: request,
            type: status == 0
                ? DioExceptionType.connectionError
                : DioExceptionType.badResponse,
            response: status == 0
                ? null
                : Response(
                    requestOptions: request,
                    statusCode: status,
                    data: status == 400
                        ? {
                            'title': ['A field error'],
                          }
                        : {'detail': 'Forbidden'},
                  ),
          ),
        );
        await tester.pumpAndSettle();
        if (status == 400) {
          await tester.ensureVisible(find.byType(TextFormField).first);
          expect(find.text('A field error'), findsOneWidget);
          expect(find.text('Open day'), findsOneWidget);
        } else if (status != 0) {
          expect(
            tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
            isNull,
          );
        } else {
          expect(repository.pages, [1, 2]);
          expect(find.text('Event page-1'), findsOneWidget);
          expect(find.text('Event page-2'), findsOneWidget);
          expect(
            tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
            isNotNull,
          );
        }
      },
    );
  }
}

class _Events implements EventRepository {
  final pages = <int>[];
  bool published = false;
  int publishCalls = 0;
  Map<String, dynamic>? fields;
  Completer<ListingEvent>? pending;
  @override
  Future<EventPage> forListing(
    String listingId, {
    int page = 1,
    bool owned = false,
  }) async {
    pages.add(page);
    return EventPage(
      results: [ListingEvent.fromJson(eventJson('page-$page'))],
      hasNext: page == 1,
    );
  }

  @override
  Future<ListingEvent> publish(
    String listingId,
    Map<String, dynamic> fields,
  ) async {
    published = true;
    publishCalls++;
    this.fields = fields;
    if (pending != null) return pending!.future;
    return ListingEvent.fromJson(eventJson('created'));
  }
}

class _NoPush implements PushNotifications {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
