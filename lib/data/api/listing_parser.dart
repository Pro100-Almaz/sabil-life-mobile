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
      ageGroups: toStringList(data['age_groups']),
      isFeatured: (data['is_featured'] ?? false) as bool,
      tags: toStringList(data['tags']),
      // Not present on list cards — defaults.
      description: (data['description'] ?? '') as String,
      highlights: toStringList(data['highlights']),
      ownerId: data['owner_id']?.toString(),
      status: parseStatus(data['status']?.toString()),
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
      description: (data['description'] ?? '') as String,
      highlights: toStringList(data['highlights']),
      tags: toStringList(data['tags']),
      ownerId: data['owner_id']?.toString(),
      status: parseStatus(data['status']?.toString()),
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
