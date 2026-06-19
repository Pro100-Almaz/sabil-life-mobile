import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Base URL for all API calls.
/// Falls back to localhost when `.env` is absent or the key is empty,
/// so the app boots and attempts real calls without a local `.env` file.
String get apiBaseUrl {
  final value = dotenv.env['API_BASE_URL'];
  if (value == null || value.isEmpty) {
    return 'http://localhost:8000/api/v1';
  }
  return value;
}
