/// Base URL for all API calls.
///
/// Compiled in at build time from `--dart-define-from-file=config/<env>.json`
/// (see `config/*.json`). Falls back to the Android-emulator host so the app
/// boots and attempts real calls even when no config file is passed.
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8000/api/v1',
);

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
