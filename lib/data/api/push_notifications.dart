import 'dart:async';
import 'dart:io' show Platform;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../repositories/device_repository.dart';

class PushNotifications {
  PushNotifications(this._devices);
  final DeviceRepository _devices;

  final _messaging = FirebaseMessaging.instance;
  final _local = FlutterLocalNotificationsPlugin();

  // Emits the data payload of a notification the user tapped.
  final _tapController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onNotificationTap => _tapController.stream;

  static const _channel = AndroidNotificationChannel(
    'default_channel', 'Notifications',
    importance: Importance.high,
  );

  String get _platform => Platform.isIOS ? "IOS" : "ANDROID";

  //call for authenticated user
  Future<void> registerForUser() async{
    final settings = await _messaging.requestPermission();
    if(settings.authorizationStatus == AuthorizationStatus.denied) return;

    await _local
        .resolvePlatformSpecificImplementation
        <AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
    await _local.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (resp) {
        // Tap on a locally-shown (foreground) notification.
      },
    );

    final token = await _messaging.getToken();

    if (token != null){
      _devices.register(fcmToken: token, platform: _platform);
    }
    _messaging.onTokenRefresh.listen(
        (t) => _devices.register(fcmToken: t, platform: _platform)
    );
    //foreground notifications
    FirebaseMessaging.onMessage.listen((m) {
      final n = m.notification;
      if (n != null){
        _local.show(
          id: n.hashCode,
          title: n.title,
          body: n.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(_channel.id, _channel.name),
            iOS: const DarwinNotificationDetails(),
          ),
        );
      }
    });

    //when notification is tapped background -> foreground
    FirebaseMessaging.onMessageOpenedApp.listen(
        (m) => _tapController.add(m.data)
    );

    //cold launch from tapped notification
    final initial = await _messaging.getInitialMessage();
    if (initial != null){
      _tapController.add(initial.data);
    }
  }
  //Call on logout
  Future<void> unregister() async{
    final token = await _messaging.getToken();
    if (token != null) _devices.unregister(token);
    await _messaging.deleteToken();
  }
}