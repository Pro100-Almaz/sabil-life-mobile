import '../models/listing.dart';

/// Shared helpers for parsing raw JSON maps into [Listing] objects.
/// Used by both [HttpCatalogRepository] and [HttpProviderRepository].
class ListingParser {
  const ListingParser._();

  static Listing fromCard(Map<String, dynamic> data) {
    return Listing(
      id: data['id'].toString(),
      title: (data['title'] ?? '') as String,
      category: parseCategory(data['category']?.toString()),
      subtitle: (data['subtitle'] ?? '') as String,
      neighborhood: (data['neighborhood'] ?? '') as String,
      lat: toDouble(data['lat']),
      lng: toDouble(data['lng']),
      rating: toDouble(data['rating']),
      reviewCount: toInt(data['review_count']),
      priceFromQar: toInt(data['price_from_qar']),
      imageUrls: toStringList(data['image_urls']),
      images: parseImages(data['images']),
      contacts: parseContacts(data['contacts']),
      ageGroups: toStringList(data['age_groups']),
      isFeatured: (data['is_featured'] ?? false) as bool,
      tags: toStringList(data['tags']),
      // Not present on list cards — defaults.
      description: (data['description'] ?? '') as String,
      highlights: toStringList(data['highlights']),
      ownerId: data['owner_id']?.toString(),
      status: parseStatus(data['status']?.toString()),
      isOnline: (data['is_online'] ?? false) as bool,
      meetingUrl: (data['meeting_url'] ?? '') as String,
      registrationUrl: (data['registration_url'] ?? '') as String,
      eventType: parseEventType(data['event_type']?.toString()),
      startsAt: parseDate(data['starts_at']),
    );
  }

  static Listing fromDetail(Map<String, dynamic> data) {
    return Listing(
      id: data['id'].toString(),
      title: (data['title'] ?? '') as String,
      category: parseCategory(data['category']?.toString()),
      subtitle: (data['subtitle'] ?? '') as String,
      neighborhood: (data['neighborhood'] ?? '') as String,
      lat: toDouble(data['lat']),
      lng: toDouble(data['lng']),
      rating: toDouble(data['rating']),
      reviewCount: toInt(data['review_count']),
      priceFromQar: toInt(data['price_from_qar']),
      imageUrls: toStringList(data['image_urls']),
      ageGroups: toStringList(data['age_groups']),
      isFeatured: (data['is_featured'] ?? false) as bool,
      images: parseImages(data['images']),
      contacts: parseContacts(data['contacts']),
      description: (data['description'] ?? '') as String,
      highlights: toStringList(data['highlights']),
      tags: toStringList(data['tags']),
      ownerId: data['owner_id']?.toString(),
      status: parseStatus(data['status']?.toString()),
      isOnline: (data['is_online'] ?? false) as bool,
      meetingUrl: (data['meeting_url'] ?? '') as String,
      registrationUrl: (data['registration_url'] ?? '') as String,
      eventType: parseEventType(data['event_type']?.toString()),
      startsAt: parseDate(data['starts_at']),
    );
  }

  static List<ListingImage> parseImages(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((m) => parseImage(Map<String, dynamic>.from(m)))
        .toList();
  }

  static ListingImage parseImage(Map<String, dynamic> data) {
    return ListingImage(
      id: data['id'].toString(),
      url: (data['url'] ?? '') as String,
      position: toInt(data['position']),
    );
  }

  static List<ListingContact> parseContacts(dynamic value) {
    if (value is! List) return const [];
    final contacts = value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .map(
          (item) => ListingContact(
            id: item['id']?.toString(),
            type: parseContactType(item['contact_type']?.toString()),
            value: (item['value'] ?? '').toString(),
            label: (item['label'] ?? '').toString(),
            position: toInt(item['position']),
          ),
        )
        .where((contact) => contact.value.trim().isNotEmpty)
        .toList();
    contacts.sort((a, b) => a.position.compareTo(b.position));
    return contacts;
  }

  static ListingContactType parseContactType(String? raw) {
    return switch (raw?.toUpperCase()) {
      'PHONE' => ListingContactType.phone,
      'EMAIL' => ListingContactType.email,
      'WEBSITE' => ListingContactType.website,
      'WHATSAPP' => ListingContactType.whatsapp,
      'INSTAGRAM' => ListingContactType.instagram,
      'TELEGRAM' => ListingContactType.telegram,
      _ => ListingContactType.website,
    };
  }

  static String serializeContactType(ListingContactType type) {
    return switch (type) {
      ListingContactType.phone => 'PHONE',
      ListingContactType.email => 'EMAIL',
      ListingContactType.website => 'WEBSITE',
      ListingContactType.whatsapp => 'WHATSAPP',
      ListingContactType.instagram => 'INSTAGRAM',
      ListingContactType.telegram => 'TELEGRAM',
    };
  }

  static CategoryType parseCategory(String? raw) {
    return switch (raw?.toUpperCase()) {
      'SCHOOLS' => CategoryType.schools,
      'NURSERIES' => CategoryType.nurseries,
      'ACTIVITIES' => CategoryType.activities,
      'ENTERTAINMENT' => CategoryType.entertainment,
      'TUTORING' => CategoryType.tutoring,
      'MASTERCLASSES' => CategoryType.masterclasses,
      'PARTNERSHIPS' => CategoryType.partnerships,
      _ => CategoryType.activities,
    };
  }

  static String serializeCategory(CategoryType category) {
    return switch (category) {
      CategoryType.schools => 'SCHOOLS',
      CategoryType.nurseries => 'NURSERIES',
      CategoryType.activities => 'ACTIVITIES',
      CategoryType.entertainment => 'ENTERTAINMENT',
      CategoryType.tutoring => 'TUTORING',
      CategoryType.masterclasses => 'MASTERCLASSES',
      CategoryType.partnerships => 'PARTNERSHIPS',
    };
  }

  static String serializeStatus(ListingStatus status) {
    return switch (status) {
      ListingStatus.draft => 'DRAFT',
      ListingStatus.pending => 'PENDING',
      ListingStatus.active => 'ACTIVE',
      ListingStatus.rejected => 'REJECTED',
    };
  }

  static ListingStatus parseStatus(String? raw) {
    return switch (raw?.toUpperCase()) {
      'DRAFT' => ListingStatus.draft,
      'PENDING' => ListingStatus.pending,
      'ACTIVE' => ListingStatus.active,
      'REJECTED' => ListingStatus.rejected,
      _ => ListingStatus.active,
    };
  }

  static MasterclassEventType parseEventType(String? raw) {
    return switch (raw?.toUpperCase()) {
      'ONE_TIME' => MasterclassEventType.oneTime,
      _ => MasterclassEventType.ongoing,
    };
  }

  static String serializeEventType(MasterclassEventType eventType) {
    return switch (eventType) {
      MasterclassEventType.oneTime => 'ONE_TIME',
      MasterclassEventType.ongoing => 'ONGOING',
    };
  }

  static DateTime? parseDate(dynamic raw) {
    if (raw == null) return null;
    return DateTime.tryParse(raw.toString())?.toLocal();
  }

  static List<String> toStringList(dynamic value) {
    if (value is! List) return const [];
    return value.map((item) => item.toString()).toList();
  }

  static int toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
