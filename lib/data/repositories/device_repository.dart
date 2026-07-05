abstract class DeviceRepository {
  Future<void> register({required String fcmToken, required String platform});
  Future<void> unregister(String fcmToken);
}
