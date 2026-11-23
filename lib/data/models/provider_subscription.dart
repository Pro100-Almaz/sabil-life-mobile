/// Public provider information returned for the authenticated client's follows.
class FollowedProvider {
  const FollowedProvider({required this.providerId, required this.displayName});

  final String providerId;
  final String displayName;

  factory FollowedProvider.fromJson(Map<String, dynamic> json) =>
      FollowedProvider(
        providerId: json['provider_id'] as String,
        displayName: json['display_name'] as String,
      );
}
