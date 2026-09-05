import 'package:flutter_test/flutter_test.dart';
import 'package:sabil_life/data/models/auth_user.dart';

void main() {
  test('parses FAMILY membership from the backend roles array', () {
    final user = AuthUser.fromJson({
      'id': '1',
      'email': 'family@example.com',
      'full_name': 'Family User',
      'roles': ['FAMILY', 'TUTOR'],
      'is_verified': true,
    });

    expect(user.isFamily, isTrue);
    expect(user.role, UserRole.family);
  });

  test('does not silently treat a tutor-only account as family', () {
    final user = AuthUser.fromJson({
      'id': '2',
      'email': 'tutor@example.com',
      'full_name': 'Tutor User',
      'roles': ['TUTOR'],
      'is_verified': true,
    });

    expect(user.isFamily, isFalse);
    expect(user.role, UserRole.tutor);
  });

  test('does not silently treat an unsupported admin role as family', () {
    final user = AuthUser.fromJson({
      'id': '3',
      'email': 'admin@example.com',
      'full_name': 'Admin User',
      'roles': ['ADMIN'],
      'is_verified': true,
    });

    expect(user.isFamily, isFalse);
  });

  test('parses a complete saved home location', () {
    final user = AuthUser.fromJson({
      'id': '4',
      'email': 'home@example.com',
      'full_name': 'Home User',
      'roles': ['FAMILY'],
      'is_verified': true,
      'home_lat': 25.369,
      'home_lng': 51.551,
    });

    expect(user.homeLocation, isNotNull);
    expect(user.homeLocation!.latitude, 25.369);
    expect(user.homeLocation!.longitude, 51.551);
  });

  test('does not construct a home from incomplete coordinates', () {
    final user = AuthUser.fromJson({
      'id': '5',
      'email': 'no-home@example.com',
      'full_name': 'No Home User',
      'roles': ['FAMILY'],
      'is_verified': true,
      'home_lat': 25.369,
      'home_lng': null,
    });

    expect(user.homeLocation, isNull);
  });
}
