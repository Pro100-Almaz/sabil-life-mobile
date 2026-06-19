import 'package:shared_preferences/shared_preferences.dart';

const String _kTokenKey = 'sabil.auth.token';

/// Single source of truth for the stored auth token.
/// Wraps [SharedPreferences] so every HTTP layer reads/writes the same key.
class AuthTokenStore {
  const AuthTokenStore();

  Future<String?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_kTokenKey);
    return (value?.isEmpty ?? true) ? null : value;
  }

  Future<void> write(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTokenKey, token);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTokenKey);
  }
}

final authTokenStore = AuthTokenStore();
