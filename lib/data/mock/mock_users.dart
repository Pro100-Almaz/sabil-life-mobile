import '../models/auth_user.dart';

/// Demo accounts the mock auth repository validates against. Passwords are
/// kept obvious on purpose — this is a mock-only build with no real auth.
class _MockAccount {
  const _MockAccount({required this.user, required this.password});

  final AuthUser user;
  final String password;
}

const String _kDemoPassword = 'demo1234';

const _MockAccount _family = _MockAccount(
  user: AuthUser(
    id: 'user-family-demo',
    email: 'family@demo',
    fullName: 'Almaz',
    role: UserRole.family,
    isVerified: true,
  ),
  password: _kDemoPassword,
);

const _MockAccount _tutor = _MockAccount(
  user: AuthUser(
    id: 'user-tutor-demo',
    email: 'tutor@demo',
    fullName: 'MathCraft Centre',
    role: UserRole.tutor,
    isVerified: true,
  ),
  password: _kDemoPassword,
);

/// Intentionally unverified so the dashboard verification banner has a real
/// account to demo against.
const _MockAccount _masterclass = _MockAccount(
  user: AuthUser(
    id: 'user-mc-demo',
    email: 'mc@demo',
    fullName: 'Canvas & Co. Studio',
    role: UserRole.masterclass,
    isVerified: false,
  ),
  password: _kDemoPassword,
);

/// In-memory registry of accounts. New `register` calls append here so they
/// survive for the rest of the session.
final List<_MockAccount> _mockAccounts = [_family, _tutor, _masterclass];

AuthUser? findMockUserByEmail(String email) {
  for (final account in _mockAccounts) {
    if (account.user.email.toLowerCase() == email.toLowerCase()) {
      return account.user;
    }
  }
  return null;
}

AuthUser? findMockUserById(String id) {
  for (final account in _mockAccounts) {
    if (account.user.id == id) return account.user;
  }
  return null;
}

AuthUser? authenticateMock(String email, String password) {
  for (final account in _mockAccounts) {
    if (account.user.email.toLowerCase() == email.toLowerCase() &&
        account.password == password) {
      return account.user;
    }
  }
  return null;
}

void registerMockAccount(AuthUser user, String password) {
  _mockAccounts.add(_MockAccount(user: user, password: password));
}

/// Stable ids referenced from mock_listings.dart and mock_inquiries.dart so
/// ownership wiring stays declarative.
const String kDemoFamilyId = 'user-family-demo';
const String kDemoTutorId = 'user-tutor-demo';
const String kDemoMasterclassId = 'user-mc-demo';
