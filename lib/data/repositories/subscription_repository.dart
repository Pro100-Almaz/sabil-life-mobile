import '../mock/mock_masterclasses.dart';
import '../models/subscription.dart';

abstract class SubscriptionRepository {
  Future<List<Subscription>> mine();
  Future<Subscription> subscribe(String listingId);
  Future<Subscription> detail(String id);
  Future<void> cancel(String id);
}

class MockSubscriptionRepository implements SubscriptionRepository {
  static const Duration _latency = Duration(milliseconds: 300);

  // In-memory list seeded with mock masterclass listing ids as confirmed.
  final List<Subscription> _subs = mockMasterclassInfo.keys.map((id) {
    return Subscription(
      id: 'sub-mock-$id',
      listingId: id,
      providerId: 'mock-provider',
      status: SubscriptionStatus.confirmed,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      privateDetails: ListingPrivateDetails(
        sessionSchedule: 'Saturdays 10am',
        exactAddress: 'Lusail City, Building 5',
        materialsRequired: ['notebook', 'pencil'],
      ),
    );
  }).toList();

  @override
  Future<List<Subscription>> mine() async {
    await Future<void>.delayed(_latency);
    return List.unmodifiable(_subs);
  }

  @override
  Future<Subscription> subscribe(String listingId) async {
    await Future<void>.delayed(_latency);
    final existing = _subs.where(
      (s) =>
          s.listingId == listingId && s.status == SubscriptionStatus.confirmed,
    );
    if (existing.isNotEmpty) {
      throw StateError(
        'You already have an active subscription to this listing.',
      );
    }
    final sub = Subscription(
      id: 'sub-${DateTime.now().millisecondsSinceEpoch}',
      listingId: listingId,
      providerId: 'mock-provider',
      status: SubscriptionStatus.confirmed,
      createdAt: DateTime.now(),
      privateDetails: const ListingPrivateDetails(
        sessionSchedule: 'Saturdays 10am',
        exactAddress: 'Lusail City, Building 5',
        materialsRequired: ['notebook'],
      ),
    );
    _subs.add(sub);
    return sub;
  }

  @override
  Future<Subscription> detail(String id) async {
    await Future<void>.delayed(_latency);
    return _subs.firstWhere(
      (s) => s.id == id,
      orElse: () => throw StateError('Subscription not found: $id'),
    );
  }

  @override
  Future<void> cancel(String id) async {
    await Future<void>.delayed(_latency);
    final idx = _subs.indexWhere((s) => s.id == id);
    if (idx == -1) throw StateError('Subscription not found: $id');
    final old = _subs[idx];
    _subs[idx] = Subscription(
      id: old.id,
      listingId: old.listingId,
      providerId: old.providerId,
      status: SubscriptionStatus.cancelled,
      createdAt: old.createdAt,
      cancelledAt: DateTime.now(),
      updatedAt: DateTime.now(),
      privateDetails: old.privateDetails,
    );
  }
}
