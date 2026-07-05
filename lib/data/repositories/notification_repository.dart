import '../models/app_notification.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> getNotifications();
  Future<int> getUnreadCount();
  Future<void> postNotificationRead(int id);
  Future<void> postNotificationReadAll();
}
