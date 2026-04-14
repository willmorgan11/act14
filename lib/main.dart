import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'services/fcm_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Messaging App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FCMService _fcmService = FCMService();
  static const String _imagePath = 'assets/images/bell.png';
  String _statusText = 'Waiting for a cloud message';
  String _bodyText = '';
  String _fcmToken = 'Fetching token...';
  Map<String, dynamic> _dataPayload = {};

  @override
  void initState() {
    super.initState();
    _initFCM();
  }

  Future<void> _initFCM() async {
    // Phase 6: capture permission settings result
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('Permission status: ${settings.authorizationStatus}');

    // Phase 5: wire payload fields to UI
    await _fcmService.initialize(onData: (message) {
      setState(() {
        _statusText = message.notification?.title ?? 'Payload received';
        _bodyText = message.notification?.body ?? '';
        _dataPayload = message.data;
      });
    });

    // Phase 6: log token
    final token = await _fcmService.getToken();
    debugPrint('FCM token: $token');
    setState(() => _fcmToken = token ?? 'No token');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Messaging')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Phase 5: status text from notification title
            Text(_statusText, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),

            // Phase 5: notification body
            if (_bodyText.isNotEmpty)
              Text(_bodyText, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),

            // Phase 5: static bell image
            Image.asset(
              _imagePath,
              height: 50,
              errorBuilder: (context, error, stackTrace) =>
              const Text('No image loaded yet'),
            ),
            const SizedBox(height: 16),

            // Phase 7: data payload display for submission evidence
            if (_dataPayload.isNotEmpty) ...[
              const Text('Data Payload:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_dataPayload.toString()),
              ),
              const SizedBox(height: 16),
            ],

            // Phase 6: FCM token for testing
            const Text('FCM Token:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SelectableText(_fcmToken),
          ],
        ),
      ),
    );
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('Background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}