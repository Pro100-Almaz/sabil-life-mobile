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
}
