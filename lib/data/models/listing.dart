const kListingFallbackAsset = 'assets/placeholder_1200x800.png';

extension ListingImageFallback on Listing {
  bool get hasImages => imageUrls.any((url) => url.trim().isNotEmpty);

  String? get primaryImageUrl =>
      hasImages ? imageUrls.firstWhere((url) => url.trim().isNotEmpty) : null;

  List<String> get imageUrlsOrEmpty =>
      imageUrls.where((url) => url.trim().isNotEmpty).toList();
}

enum CategoryType {
  schools,
  nurseries,
  activities,
  entertainment,
  tutoring,
  masterclasses,
  partnerships,
}

/// Lifecycle a provider's own listing moves through. Non-provider listings
/// (schools, partner offers seeded as platform content) stay [active].
enum ListingStatus { draft, pending, active, rejected }

class Listing {
  const Listing({
    required this.id,
    required this.title,
    required this.category,
    required this.subtitle,
    required this.neighborhood,
    required this.lat,
    required this.lng,
    required this.rating,
    required this.reviewCount,
    required this.priceFromQar,
    required this.imageUrls,
    required this.ageGroups,
    required this.isFeatured,
    required this.description,
    required this.highlights,
    this.ownerId,
    this.status = ListingStatus.active,
  });

  final String id;
  final String title;
  final CategoryType category;
  final String subtitle;
  final String neighborhood;
  final double lat;
  final double lng;
  final double rating;
  final int reviewCount;

  /// 0 = free / not applicable.
  final int priceFromQar;
  final List<String> imageUrls;
  final List<String> ageGroups;
  final bool isFeatured;
  final String description;
  final List<String> highlights;

  /// `AuthUser.id` of the provider that owns this listing. `null` = platform-
  /// seeded content (schools, partner offers etc.) that no provider manages.
  final String? ownerId;
  final ListingStatus status;

  Listing copyWith({
    String? id,
    String? title,
    CategoryType? category,
    String? subtitle,
    String? neighborhood,
    double? lat,
    double? lng,
    double? rating,
    int? reviewCount,
    int? priceFromQar,
    List<String>? imageUrls,
    List<String>? ageGroups,
    bool? isFeatured,
    String? description,
    List<String>? highlights,
    String? Function()? ownerId,
    ListingStatus? status,
  }) {
    return Listing(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      subtitle: subtitle ?? this.subtitle,
      neighborhood: neighborhood ?? this.neighborhood,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      priceFromQar: priceFromQar ?? this.priceFromQar,
      imageUrls: imageUrls ?? this.imageUrls,
      ageGroups: ageGroups ?? this.ageGroups,
      isFeatured: isFeatured ?? this.isFeatured,
      description: description ?? this.description,
      highlights: highlights ?? this.highlights,
      ownerId: ownerId != null ? ownerId() : this.ownerId,
      status: status ?? this.status,
    );
  }
}
