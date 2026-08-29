import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sabil_life/data/api/client.dart';
import 'package:sabil_life/data/api/push_notifications.dart';
import 'package:flutter/foundation.dart';
import '../../data/api/auth_token_store.dart';
import '../../data/models/auth_user.dart';
import '../../data/repositories/auth_repository.dart';
import 'provider_providers.dart';

enum AuthStatus { unknown, authenticating, unauthenticated, authenticated }

enum ActiveInterface { family, tutor, masterclass }

extension ActiveInterfaceX on ActiveInterface {
  /// Root location of this interface's shell. Each provider role has its own
  /// route tree so the two interfaces stay structurally separate.
  String get basePath => switch (this) {
    ActiveInterface.tutor => '/provider/tutor',
    ActiveInterface.masterclass => '/provider/masterclass',
    ActiveInterface.family => '/',
  };

  bool get isProvider =>
      this == ActiveInterface.tutor || this == ActiveInterface.masterclass;
}

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

/// Singleton repository — swap [MockAuthRepository] for an HTTP implementation
/// in one line when the backend lands.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => HttpAuthRepository(),
);

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repo, {required PushNotifications push, this.onLogout})
    : _push = push,
      super(const AuthState.unknown());

  final AuthRepository _repo;
  final VoidCallback? onLogout;
  final PushNotifications _push;

  Future<void> restore() async {
    final token = await authTokenStore.read();
    if (token == null) {
      state = const AuthState.unauthenticated();
      return;
    }
    try {
      final user = await _repo.me(token);
      state = AuthState.authenticated(user: user, token: token);
      unawaited(_push.registerForUser());
    } on AuthException {
      await authTokenStore.clear();
      state = const AuthState.unauthenticated();
    }
  }

  Future<bool> login(String email, String password) async {
    state = const AuthState.authenticating();
    try {
      final session = await _repo.login(email, password);
      await _persist(session.token);
      unawaited(_push.registerForUser());
      state = AuthState.authenticated(user: session.user, token: session.token);
      return true;
    } on AuthException catch (e) {
      state = AuthState.unauthenticated(error: e.message);
      return false;
    }
  }

  /// Step 1: validate inputs and email a verification code. Does not create
  /// a session — returns true if the code was sent so the UI can advance to
  /// the code-entry step.
  Future<bool> requestRegistrationCode({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = const AuthState.authenticating();
    try {
      await _repo.requestRegistrationCode(
        email: email,
        password: password,
        fullName: fullName,
      );
      state = const AuthState.unauthenticated(); // idle, no error
      return true;
    } on AuthException catch (e) {
      state = AuthState.unauthenticated(error: e.message);
      return false;
    }
  }

  /// Step 2: confirm the emailed code. On success the account is created and
  /// the user is signed in.
  Future<bool> confirmRegistration({
    required String email,
    required String code,
  }) async {
    state = const AuthState.authenticating();
    try {
      final session = await _repo.confirmRegistration(email: email, code: code);
      await _persist(session.token);
      unawaited(_push.registerForUser());
      state = AuthState.authenticated(user: session.user, token: session.token);
      return true;
    } on AuthException catch (e) {
      state = AuthState.unauthenticated(error: e.message);
      return false;
    }
  }

  Future<bool> requestPasswordReset({required String email}) async {
    state = const AuthState.authenticating();

    try {
      await _repo.requestPasswordReset(email: email);
      state = const AuthState.unauthenticated();
      return true;
    } on AuthException catch (e) {
      state = AuthState.unauthenticated(error: e.message);
      return false;
    }
  }

  Future<bool> confirmPasswordReset({
    required String email,
    required String code,
    required String password,
    required String password2,
  }) async {
    state = const AuthState.authenticating();

    try {
      await _repo.confirmPasswordReset(
        email: email,
        code: code,
        password: password,
        password2: password2,
      );
      state = const AuthState.unauthenticated();
      return true;
    } on AuthException catch (e) {
      state = AuthState.unauthenticated(error: e.message);
      return false;
    }
  }

  /// Re-fetches the signed-in user from the backend without disturbing the
  /// session token. Used when the active interface changes so provider data is
  /// always current. No-op when logged out; guarded so it never resurrects a
  /// session that ended while the request was in flight.
  Future<void> refreshUser() async {
    final token = state.token;
    if (token == null || !state.isAuthenticated) return;
    try {
      final user = await _repo.me(token);
      if (!state.isAuthenticated || state.token != token) return;
      state = AuthState.authenticated(user: user, token: token);
    } on AuthException {
      // Leave the current session untouched; a hard auth failure surfaces
      // through the normal request paths.
    }
  }

  /// Returns null on success, otherwise the backend validation message.
  Future<String?> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPassword2,
  }) async {
    try {
      await _repo.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
        newPassword2: newPassword2,
      );
      await authTokenStore.clear();
      onLogout?.call();
      state = const AuthState.unauthenticated();
      return null;
    } on AuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> requestPersonalInformationChange({
    required String newName,
    required String newEmail,
    required String newPassword,
    required String newPassword2,
  }) async {
    final user = state.user;
    if (user == null) return "Please sign in again.";
    try {
      await _repo.requestPersonalInformationChange(
        user: user,
        newName: newName,
        newEmail: newEmail,
        newPassword: newPassword,
        newPassword2: newPassword2,
      );
      return null;
    } on AuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> confirmPersonalInformationChange({
    required String code,
    required bool passwordChanged,
  }) async {
    final user = state.user;
    final token = state.token;
    if (user == null || token == null) return "Please sign in again.";
    try {
      final updatedUser = await _repo.confirmPersonalInformationChange(
        user: user,
        code: code,
      );
      if (passwordChanged) {
        await authTokenStore.clear();
        onLogout?.call();
        state = const AuthState.unauthenticated();
      } else {
        state = AuthState.authenticated(user: updatedUser, token: token);
      }
      return null;
    } on AuthException catch (e) {
      return e.message;
    }
  }

  Future<void> logout() async {
    try {
      await _push.unregister().timeout(const Duration(seconds: 5));
    } catch (e) {
      if (kDebugMode) {
        debugPrint("push unregister failed (ignored): $e");
      }
    }
    await _repo.logout();
    await authTokenStore.clear();
    onLogout?.call();
    state = const AuthState.unauthenticated();
  }

  Future<void> _persist(String token) async {
    await authTokenStore.write(token);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final notifier = AuthNotifier(
    ref.watch(authRepositoryProvider),
    push: ref.watch(pushNotificationsProvider),
    onLogout: () => ref.read(activeInterfaceProvider.notifier).state =
        ActiveInterface.family,
  );
  // Switching interfaces refreshes the user and provider data from the backend.
  ref.listen<ActiveInterface>(activeInterfaceProvider, (prev, next) {
    if (prev == next) return;
    notifier.refreshUser();
    ref.invalidate(providerProfileProvider);
    ref.invalidate(myVerificationsProvider);
  });
  return notifier;
});

final activeInterfaceProvider = StateProvider<ActiveInterface>(
  (ref) => ActiveInterface.family,
);
