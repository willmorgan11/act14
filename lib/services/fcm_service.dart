import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> initialize({required void Function(RemoteMessage) onData}) async {
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    FirebaseMessaging.onMessage.listen((message) => onData(message));
    FirebaseMessaging.onMessageOpenedApp.listen((message) => onData(message));

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) onData(initialMessage);
  }

  Future<String?> getToken() => messaging.getToken();
}