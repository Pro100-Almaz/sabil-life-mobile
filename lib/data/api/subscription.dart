import 'package:dio/dio.dart';

import '../models/subscription.dart';
import '../repositories/subscription_repository.dart';
import 'api_client.dart';

class HttpSubscriptionRepository implements SubscriptionRepository {
  HttpSubscriptionRepository();

  Dio get _dio => apiClient.dio;

  @override
  Future<List<Subscription>> mine() async {
    try {
      final response = await _dio.get('/subscriptions/');
      final data = response.data;
      final items = data is Map<String, dynamic>
          ? (data['results'] as List? ?? [])
          : (data as List? ?? []);
      return items
          .whereType<Map>()
          .map((item) => _parse(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (e) {
      throw StateError(_extractError(e));
    }
  }

  @override
  Future<Subscription> subscribe(String listingId) async {
    try {
      final response = await _dio.post(
        '/subscriptions/',
        data: {'listing_id': listingId},
      );
      return _parse(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw StateError(
          'You already have an active subscription to this listing.',
        );
      }
      throw StateError(_extractError(e));
    }
  }

  @override
  Future<Subscription> detail(String id) async {
    try {
      final response = await _dio.get('/subscriptions/$id/');
      return _parse(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      throw StateError(_extractError(e));
    }
  }

  @override
  Future<void> cancel(String id) async {
    try {
      await _dio.delete('/subscriptions/$id/');
    } on DioException catch (e) {
      throw StateError(_extractError(e));
    }
  }

  static Subscription _parse(Map<String, dynamic> data) {
    ListingPrivateDetails? privateDetails;
    final raw = data['listing_private_details'];
    if (raw is Map) {
      final d = Map<String, dynamic>.from(raw);
      privateDetails = ListingPrivateDetails(
        sessionSchedule: d['session_schedule']?.toString(),
        exactAddress: d['exact_address']?.toString(),
        materialsRequired: _toStringList(d['materials_required']),
      );
    }

    return Subscription(
      id: data['id'].toString(),
      listingId: data['listing_id']?.toString() ?? '',
      providerId: data['provider_id']?.toString() ?? '',
      status: SubscriptionStatus.fromBackend(data['status']?.toString()),
      createdAt: _parseDate(data['created_at']) ?? DateTime.now(),
      cancelledAt: _parseDate(data['cancelled_at']),
      updatedAt: _parseDate(data['updated_at']),
      privateDetails: privateDetails,
    );
  }

  static DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    return DateTime.tryParse(raw.toString());
  }

  static List<String> _toStringList(dynamic value) {
    if (value is! List) return const [];
    return value.map((item) => item.toString()).toList();
  }

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      if (data.containsKey('detail')) return data['detail'].toString();
      if (data.containsKey('message')) return data['message'].toString();
      if (data.isNotEmpty) {
        final first = data.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
        return first.toString();
      }
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}
