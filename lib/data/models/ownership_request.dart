enum OwnershipRequestStatus { pending, approved, rejected, cancelled }

extension OwnershipRequestStatusX on OwnershipRequestStatus {
  static OwnershipRequestStatus fromBackend(String? value) => switch (value) {
    'APPROVED' => OwnershipRequestStatus.approved,
    'REJECTED' => OwnershipRequestStatus.rejected,
    'CANCELLED' => OwnershipRequestStatus.cancelled,
    _ => OwnershipRequestStatus.pending,
  };

  String get label => switch (this) {
    OwnershipRequestStatus.pending => 'Pending',
    OwnershipRequestStatus.approved => 'Approved',
    OwnershipRequestStatus.rejected => 'Rejected',
    OwnershipRequestStatus.cancelled => 'Cancelled',
  };
}

class OwnershipRequest {
  const OwnershipRequest({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    required this.status,
    required this.message,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String listingId;
  final String listingTitle;
  final OwnershipRequestStatus status;
  final String message;
  final String comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get canCancel => status == OwnershipRequestStatus.pending;

  factory OwnershipRequest.fromJson(Map<String, dynamic> json) {
    DateTime date(String key) =>
        DateTime.tryParse(json[key]?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
    return OwnershipRequest(
      id: (json['id'] as num).toInt(),
      listingId: json['listing_id']?.toString() ?? '',
      listingTitle: json['listing_title']?.toString() ?? '',
      status: OwnershipRequestStatusX.fromBackend(json['status']?.toString()),
      message: json['message']?.toString() ?? '',
      comment: json['comment']?.toString() ?? '',
      createdAt: date('created_at'),
      updatedAt: date('updated_at'),
    );
  }
}
