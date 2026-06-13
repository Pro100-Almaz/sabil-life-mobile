enum CategoryType {
  schools,
  nurseries,
  activities,
  entertainment,
  tutoring,
  masterclasses,
  partnerships,
}

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
    );
  }
}
