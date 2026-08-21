import 'package:url_launcher/url_launcher.dart';

import '../../data/models/listing.dart';

String? validateListingContact(ListingContactType type, String rawValue) {
  final value = rawValue.trim();
  if (value.isEmpty) return 'required';

  switch (type) {
    case ListingContactType.email:
      final email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
      return email.hasMatch(value) ? null : 'email';
    case ListingContactType.phone:
      if (!RegExp(r'^[+\d\s().-]+$').hasMatch(value)) return 'phone';
      final digits = value.replaceAll(RegExp(r'\D'), '');
      return digits.length >= 7 && digits.length <= 15 ? null : 'phone';
    case ListingContactType.website:
      return _validWebUri(value) ? null : 'url';
    case ListingContactType.instagram:
      return _validDomain(value, const {'instagram.com'}) ? null : 'url';
    case ListingContactType.whatsapp:
      return _validDomain(value, const {
            'wa.me',
            'whatsapp.com',
            'api.whatsapp.com',
          })
          ? null
          : 'url';
    case ListingContactType.telegram:
      return _validDomain(value, const {'t.me', 'telegram.me', 'telegram.org'})
          ? null
          : 'url';
  }
}

bool _validWebUri(String value) {
  final uri = Uri.tryParse(value);
  return uri != null &&
      (uri.scheme == 'http' || uri.scheme == 'https') &&
      uri.host.isNotEmpty;
}

bool _validDomain(String value, Set<String> domains) {
  if (!_validWebUri(value)) return false;
  final host = Uri.parse(value).host.toLowerCase();
  return domains.any((domain) => host == domain || host.endsWith('.$domain'));
}

Uri? listingContactUri(ListingContact contact) {
  final value = contact.value.trim();
  if (validateListingContact(contact.type, value) != null) return null;

  return switch (contact.type) {
    ListingContactType.phone => Uri(scheme: 'tel', path: value),
    ListingContactType.email => Uri(scheme: 'mailto', path: value),
    ListingContactType.website ||
    ListingContactType.whatsapp ||
    ListingContactType.instagram ||
    ListingContactType.telegram => Uri.parse(value),
  };
}

Future<bool> openListingContact(ListingContact contact) async {
  final uri = listingContactUri(contact);
  if (uri == null) return false;
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
