import 'package:url_launcher/url_launcher.dart';

Future<bool> openMeetingLink(String meetingUrl) async {
  final uri = Uri.tryParse(meetingUrl.trim());

  if (uri == null ||
      (uri.scheme != 'http' && uri.scheme != 'https') ||
      uri.host.isEmpty) {
    return false;
  }

  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
