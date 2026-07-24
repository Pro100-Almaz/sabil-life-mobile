import '../api/api_config.dart';

const kListingFallbackAsset = 'assets/placeholder_1200x800.png';

extension ListingImageFallback on Listing {
  bool get hasImages => imageUrls.any((url) => url.trim().isNotEmpty);

  String? get primaryImageUrl => hasImages
      ? resolveMediaUrl(imageUrls.firstWhere((url) => url.trim().isNotEmpty))
      : null;

  List<String> get imageUrlsOrEmpty => imageUrls
      .where((url) => url.trim().isNotEmpty)
      .map(resolveMediaUrl)
      .toList();
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

/// A single image attached to a listing, managed as a first-class sub-resource
/// (Option C). [id] is the server identity used to delete it; [url] is the raw
/// storage URL — always render through [displayUrl] so the media proxy applies.
class ListingImage {
  const ListingImage({required this.id, required this.url, this.position = 0});

  final String id;
  final String url;
  final int position;

  /// Proxy-resolved URL for display. Never store or send this back.
  String get displayUrl => resolveMediaUrl(url);
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
    required this.rating,
    required this.reviewCount,
    required this.priceFromQar,
    required this.imageUrls,
    required this.ageGroups,
    required this.isFeatured,
    required this.description,
    required this.highlights,
    this.isOnline = false,
    this.lat = 0,
    this.lng = 0,
    this.meetingUrl = '',
    this.tags = const [],
    this.images = const [],
    this.ownerId,
    this.status = ListingStatus.active,
  });

  final String id;
  final String title;
  final CategoryType category;
  final String subtitle;
  final String neighborhood;
  final double rating;
  final int reviewCount;
  final bool isOnline;

  /// if isOnline = true 
  final String meetingUrl;
  /// if isOnline = false 
  final double lat;
  final double lng;

  /// 0 = free / not applicable.
  final int priceFromQar;
  final List<String> imageUrls;
  final List<String> ageGroups;
  final bool isFeatured;
  final String description;
  final List<String> highlights;

  /// Category-scoped filter tags this listing carries (e.g. `British`,
  /// `Swimming`). Mirrors the backend `tags` array; drives the tag-pill rail
  /// on the category screen.
  final List<String> tags;

  /// Images as first-class objects (id + url + position). Empty on public
  /// card payloads; populated on detail and provider-owned listings.
  final List<ListingImage> images;

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
    List<String>? tags,
    List<ListingImage>? images,
    String? Function()? ownerId,
    ListingStatus? status,
    bool? isOnline,
    String? meetingUrl,
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
      tags: tags ?? this.tags,
      images: images ?? this.images,
      ownerId: ownerId != null ? ownerId() : this.ownerId,
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
      meetingUrl: meetingUrl ?? this.meetingUrl,
    );
  }
}
