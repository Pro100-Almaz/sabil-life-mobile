enum SubscriptionStatus {
  confirmed,
  cancelled;

  String toBackend() => switch (this) {
    SubscriptionStatus.confirmed => 'CONFIRMED',
    SubscriptionStatus.cancelled => 'CANCELLED',
  };

  static SubscriptionStatus fromBackend(String? raw) =>
      switch (raw?.toUpperCase()) {
        'CANCELLED' => SubscriptionStatus.cancelled,
        _ => SubscriptionStatus.confirmed,
      };
}

class ListingPrivateDetails {
  const ListingPrivateDetails({
    this.sessionSchedule,
    this.exactAddress,
    this.materialsRequired = const [],
  });

  final String? sessionSchedule;
  final String? exactAddress;
  final List<String> materialsRequired;
}

class Subscription {
  const Subscription({
    required this.id,
    required this.listingId,
    required this.providerId,
    required this.status,
    required this.createdAt,
    this.cancelledAt,
    this.updatedAt,
    this.privateDetails,
    this.listingTitle,
    this.familyName,
    this.familyId,
  });

  final String id;
  final String listingId;
  final String providerId;
  final SubscriptionStatus status;
  final DateTime createdAt;
  final DateTime? cancelledAt;
  final DateTime? updatedAt;

  /// Only populated by the subscription detail endpoint (§4.5).
  final ListingPrivateDetails? privateDetails;

  /// Provider-side roster fields (§4.5 ProviderSubscription shape).
  final String? listingTitle;
  final String? familyName;
  final String? familyId;
}
