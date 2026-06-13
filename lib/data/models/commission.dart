enum CommissionStatus { pending, paid }

/// Platform commission accrued when a provider accepts an inquiry. Mock-only
/// today; the shape matches the planned backend `/provider/earnings/` payload.
class Commission {
  const Commission({
    required this.id,
    required this.inquiryId,
    required this.providerId,
    required this.amountQar,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String inquiryId;
  final String providerId;
  final int amountQar;
  final CommissionStatus status;
  final DateTime createdAt;
}

/// Flat commission charged per accepted inquiry. Backend will eventually
/// return this from a rules endpoint; for the mock build it's a constant.
const int kInquiryCommissionQar = 50;
