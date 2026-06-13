import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/auth_user.dart';
import '../../data/repositories/auth_repository.dart';

enum AuthStatus { unknown, authenticating, unauthenticated, authenticated }

class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.token,
    this.errorMessage,
  });

  const AuthState.unknown() : this(status: AuthStatus.unknown);

  const AuthState.unauthenticated({String? error})
    : this(status: AuthStatus.unauthenticated, errorMessage: error);

  const AuthState.authenticating() : this(status: AuthStatus.authenticating);

  const AuthState.authenticated({required AuthUser user, required String token})
    : this(status: AuthStatus.authenticated, user: user, token: token);

  final AuthStatus status;
  final AuthUser? user;
  final String? token;
  final String? errorMessage;

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;
  bool get isProvider => user?.isProvider ?? false;
}

const String _kTokenPrefsKey = 'sabil.auth.token';

/// Singleton repository — swap [MockAuthRepository] for an HTTP implementation
/// in one line when the backend lands.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => MockAuthRepository(),
);

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repo) : super(const AuthState.unknown());

  final AuthRepository _repo;

  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_kTokenPrefsKey);
    if (token == null) {
      state = const AuthState.unauthenticated();
      return;
    }
    try {
      final user = await _repo.me(token);
      state = AuthState.authenticated(user: user, token: token);
    } on AuthException {
      await prefs.remove(_kTokenPrefsKey);
      state = const AuthState.unauthenticated();
    }
  }

  Future<bool> login(String email, String password) async {
    state = const AuthState.authenticating();
    try {
      final session = await _repo.login(email, password);
      await _persist(session.token);
      state = AuthState.authenticated(user: session.user, token: session.token);
      return true;
    } on AuthException catch (e) {
      state = AuthState.unauthenticated(error: e.message);
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    UserRole role = UserRole.family,
  }) async {
    state = const AuthState.authenticating();
    try {
      final session = await _repo.register(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
      );
      await _persist(session.token);
      state = AuthState.authenticated(user: session.user, token: session.token);
      return true;
    } on AuthException catch (e) {
      state = AuthState.unauthenticated(error: e.message);
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTokenPrefsKey);
    state = const AuthState.unauthenticated();
  }

  Future<void> _persist(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTokenPrefsKey, token);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.watch(authRepositoryProvider)),
);
