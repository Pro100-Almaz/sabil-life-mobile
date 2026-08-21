import 'package:flutter_test/flutter_test.dart';
import 'package:sabil_life/core/util/listing_contact.dart';
import 'package:sabil_life/data/api/listing_parser.dart';
import 'package:sabil_life/data/models/listing.dart';

void main() {
  group('listing contacts', () {
    test('parses and orders backend contacts', () {
      final contacts = ListingParser.parseContacts([
        {
          'id': 'website-id',
          'contact_type': 'WEBSITE',
          'value': 'https://example.com',
          'label': 'Website',
          'position': 1,
        },
        {
          'id': 'phone-id',
          'contact_type': 'PHONE',
          'value': '+974 5555 1234',
          'label': 'Reception',
          'position': 0,
        },
      ]);

      expect(contacts, hasLength(2));
      expect(contacts.first.type, ListingContactType.phone);
      expect(contacts.first.label, 'Reception');
      expect(contacts.last.type, ListingContactType.website);
    });

    test('serializes every contact type to the backend value', () {
      expect(
        ListingContactType.values.map(ListingParser.serializeContactType),
        ['PHONE', 'EMAIL', 'WEBSITE', 'WHATSAPP', 'INSTAGRAM', 'TELEGRAM'],
      );
    });

    test('validates contact values and social domains', () {
      expect(
        validateListingContact(ListingContactType.email, 'hello@example.com'),
        isNull,
      );
      expect(
        validateListingContact(ListingContactType.email, 'not-an-email'),
        'email',
      );
      expect(
        validateListingContact(ListingContactType.phone, '+974 5555 1234'),
        isNull,
      );
      expect(
        validateListingContact(
          ListingContactType.instagram,
          'https://youtube.com/example',
        ),
        'url',
      );
      expect(
        validateListingContact(
          ListingContactType.instagram,
          'https://instagram.com/example',
        ),
        isNull,
      );
    });

    test('builds phone and email launch URIs', () {
      expect(
        listingContactUri(
          const ListingContact(
            type: ListingContactType.phone,
            value: '+974 5555 1234',
          ),
        )?.scheme,
        'tel',
      );
      expect(
        listingContactUri(
          const ListingContact(
            type: ListingContactType.email,
            value: 'hello@example.com',
          ),
        )?.scheme,
        'mailto',
      );
    });
  });
}
