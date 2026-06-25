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

String resolveMediaUrl(String url) {
  final trimmed = url.trim();
  if (trimmed.isEmpty) return trimmed;

  final parsed = Uri.tryParse(trimmed);
  if (parsed == null || !parsed.hasScheme) {
    return trimmed;
  }

  final host = parsed.host.toLowerCase();
  const proxyHosts = {'localhost', '127.0.0.1', '10.0.2.2', 'minio'};
  if (!proxyHosts.contains(host)) {
    return trimmed;
  }

  return '$apiBaseUrl/core/media/?url=${Uri.encodeQueryComponent(trimmed)}';
}
