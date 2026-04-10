import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'auth_service.dart';

class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize(AuthService authService) async {
    // 1. Request Permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    }

    // 2. Setup Local Notifications for Foreground
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');

    var initializationSettingsDarwin =
        const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    // Using named parameter 'settings' for initialize method as required by v21.0.0+
    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
    );

    // 3. Get FCM Token
    String? token = await _messaging.getToken();
    if (token != null) {
      print("FCM Token: $token");
      await authService.updateFcmToken(token);
    }

    // 4. Token Refresh Listener
    _messaging.onTokenRefresh.listen((newToken) {
      authService.updateFcmToken(newToken);
    });

    // 5. Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Got a message whilst in the foreground!");
      if (message.notification != null) {
        _showLocalNotification(message); // Pass the whole message
      }
    });
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'contact_events',
      'Contact Events',
      channelDescription: 'Notifications for birthdays and anniversaries',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: const DarwinNotificationDetails(),
      macOS: const DarwinNotificationDetails(),
    );

    await _localNotificationsPlugin.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: platformChannelSpecifics,
      payload: message.data.toString(), // Store the new data here
    );
  }
}
