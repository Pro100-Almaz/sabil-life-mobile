import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sabil_life/data/api/notifications.dart';
import 'package:sabil_life/data/models/app_notification.dart';
import 'package:sabil_life/data/repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => HttpNotificationRepository(),
);

final notificationsFeedProvider =
    FutureProvider.autoDispose<List<AppNotification>>(
      (ref) => ref.watch(notificationRepositoryProvider).getNotifications(),
    );

final unreadCountProvider = FutureProvider.autoDispose<int>(
  (ref) => ref.watch(notificationRepositoryProvider).getUnreadCount(),
);
