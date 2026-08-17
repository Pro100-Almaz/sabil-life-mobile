import 'package:url_launcher/url_launcher.dart';

Uri? linkedinProfileUri(String value) {
  final uri = Uri.tryParse(value.trim());
  if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
    return null;
  }

  final host = uri.host.toLowerCase();
  if (host != 'linkedin.com' && !host.endsWith('.linkedin.com')) return null;
  return uri;
}

bool isValidOptionalLinkedInUrl(String value) =>
    value.trim().isEmpty || linkedinProfileUri(value) != null;

Future<bool> openLinkedInProfile(String value) async {
  final uri = linkedinProfileUri(value);
  if (uri == null) return false;
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
