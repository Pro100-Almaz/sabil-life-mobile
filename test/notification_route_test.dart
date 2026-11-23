import 'package:flutter_test/flutter_test.dart';
import 'package:sabil_life/core/state/auth_provider.dart';
import 'package:sabil_life/core/util/notification_route.dart';
import 'package:sabil_life/data/models/auth_user.dart';

AuthUser _user(Set<String> roles) => AuthUser(
  id: 'u',
  email: 'u@demo',
  fullName: 'U',
  role: UserRole.family,
  isVerified: true,
  roles: roles,
);

void main() {
  final masterclass = _user({'MASTERCLASS'});
  final tutor = _user({'TUTOR'});
  const event = {'listing_id': 'l1', 'event_id': 'e1'};

  test('provider events push the listing events page', () {
    final target = notificationTarget('PROVIDER_EVENT', event, null)!;
    expect(target.location, '/listing/l1/events');
    expect(target.push, isTrue);
    expect(target.interface, isNull);
  });

  test('non-event types carrying event ids are not routed as events', () {
    expect(notificationTarget('INQUIRY_REQUEST', event, tutor), isNull);
  });

  test('ownership decisions open masterclass listings only with the role', () {
    const data = {
      'ownership_request_id': '3',
      'listing_id': 'l1',
      'status': 'APPROVED',
    };
    final target = notificationTarget('OWNERSHIP_APPROVED', data, masterclass)!;
    expect(target.location, '/provider/masterclass/listings');
    expect(target.interface, ActiveInterface.masterclass);
    expect(notificationTarget('OWNERSHIP_APPROVED', data, tutor), isNull);
  });

  test('verification decisions open the matching provider settings', () {
    const data = {
      'verification_id': '1',
      'provider_type': 'TUTOR',
      'status': 'APPROVED',
    };
    final target = notificationTarget('PROVIDER_APPROVED', data, tutor)!;
    expect(target.location, '/provider/tutor/settings');
    expect(target.interface, ActiveInterface.tutor);
    expect(notificationTarget('PROVIDER_APPROVED', data, masterclass), isNull);
  });

  test('payloads without a type are inferred from their keys', () {
    expect(
      notificationTarget(null, {
        'ownership_request_id': '3',
        'listing_id': 'l1',
        'status': 'REJECTED',
      }, masterclass)?.location,
      '/provider/masterclass/listings',
    );
    expect(
      notificationTarget(null, event, null)?.location,
      '/listing/l1/events',
    );
    expect(
      notificationTarget(null, {'inquiry_id': '9', 'status': 'PENDING'}, tutor),
      isNull,
    );
  });
}
