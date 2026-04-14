import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FCMService {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize({required void Function(RemoteMessage) onData}) async {
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    await _localNotifications.initialize(
      settings: InitializationSettings(android: androidSettings),
    );

    await AndroidFlutterLocalNotificationsPlugin().createNotificationChannel(
      const AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.high,
      ),
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      onData(message);
      _showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) => onData(message));

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) onData(initialMessage);
  }

  Future<void> _showNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  Future<String?> getToken() => messaging.getToken();
}