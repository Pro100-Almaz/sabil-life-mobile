import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/auth_user.dart';
import '../router/app_router.dart';
import '../state/auth_provider.dart';
import 'provider_event_location.dart';

/// Where tapping a notification should take the user.
class NotificationTarget {
  const NotificationTarget(this.location, {this.interface, this.push = false});

  final String location;

  /// Provider workspace to switch into first, if any.
  final ActiveInterface? interface;

  /// Push on top of the current stack (detail pages) instead of `go`.
  final bool push;
}

/// Resolves a notification to a destination. Shared by the in-app inbox and
/// device-push taps so both always route the same way.
///
/// Routes by [type] (the backend `NotificationType`); if a payload arrives
/// without one, the type is inferred from its data keys. Returns null when
/// the notification has no destination beyond the inbox, or when the user
/// lacks the role the destination needs.
NotificationTarget? notificationTarget(
  String? type,
  Map<String, dynamic> data,
  AuthUser? user,
) {
  switch (type ?? _inferType(data)) {
    case 'PROVIDER_EVENT':
      final location = providerEventLocation(data);
      return location == null ? null : NotificationTarget(location, push: true);
    case 'OWNERSHIP_APPROVED' || 'OWNERSHIP_REJECTED':
    case 'LISTING_APPROVED' || 'LISTING_REJECTED':
      if (user == null || !user.hasMasterclassRole) return null;
      return NotificationTarget(
        '${ActiveInterface.masterclass.basePath}/listings',
        interface: ActiveInterface.masterclass,
      );
    case 'PROVIDER_APPROVED' || 'PROVIDER_REJECTED':
      final interface = data['provider_type']?.toString() == 'MASTERCLASS'
          ? ActiveInterface.masterclass
          : ActiveInterface.tutor;
      final hasRole = interface == ActiveInterface.masterclass
          ? user?.hasMasterclassRole ?? false
          : user?.hasTutorRole ?? false;
      if (!hasRole) return null;
      return NotificationTarget(
        '${interface.basePath}/settings',
        interface: interface,
      );
    default:
      return null;
  }
}

String? _inferType(Map<String, dynamic> data) {
  final approved = data['status']?.toString() == 'APPROVED';
  if (data.containsKey('event_id')) return 'PROVIDER_EVENT';
  if (data.containsKey('ownership_request_id')) {
    return approved ? 'OWNERSHIP_APPROVED' : 'OWNERSHIP_REJECTED';
  }
  if (data.containsKey('verification_id')) {
    return approved ? 'PROVIDER_APPROVED' : 'PROVIDER_REJECTED';
  }
  if (data.containsKey('listing_id') && data.containsKey('status')) {
    return data['status']?.toString() == 'ACTIVE'
        ? 'LISTING_APPROVED'
        : 'LISTING_REJECTED';
  }
  return null;
}

/// Navigates to [target], switching workspace first when it needs one.
/// A pushed page that is already on top is not pushed again.
void openNotificationTarget(WidgetRef ref, NotificationTarget target) {
  final interface = target.interface;
  if (interface != null) {
    ref.read(activeInterfaceProvider.notifier).state = interface;
  }
  final router = ref.read(routerProvider);
  if (!target.push) {
    router.go(target.location);
    return;
  }
  final current = router.routerDelegate.currentConfiguration.uri.toString();
  if (current != target.location) router.push(target.location);
}
