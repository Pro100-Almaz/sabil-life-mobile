import 'package:url_launcher/url_launcher.dart';

Future<bool> openDirecions({required double lat, required double lng}){
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1'
        '&destination=$lat,$lng'
        '&travelmode=driving',
    );
    return launchUrl(uri, mode: LaunchMode.externalApplication);
}