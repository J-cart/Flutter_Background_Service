import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotification {
  static const NOTIF_CHANNEL_ID = 'my_foreground'; // id
  static const NOTIF_CHANNEL_NAME = 'MY FOREGROUND SERVICE'; //title
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      debugPrint('notification payload: $payload');
      print('notification payload: $payload');
    }
    print('notification payload: $payload');
    // await action();
  }

  static init() async {
    /// OPTIONAL, using custom notification channel id
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      NOTIF_CHANNEL_ID, NOTIF_CHANNEL_NAME,
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.low, // importance must be at low or higher level
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    if (Platform.isIOS || Platform.isAndroid) {
      await flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(
          iOS: DarwinInitializationSettings(),
          android: AndroidInitializationSettings('ic_bg_service_small'),
        ),
        //still figuring how these method parameters work...

        // onDidReceiveBackgroundNotificationResponse: (details) {
        //   print('notification payload: TOP!');
        // },
        // onDidReceiveNotificationResponse: (details) {
        //   print('notification payload: BOTTOM!');
        // },
      );
    }

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static showSimpleNotification(
    int id,
    String? title,
    String? body,
    NotificationDetails? notificationDetails, {
    String? payload,
  }) async {
    const notifDetails = NotificationDetails(
        android: AndroidNotificationDetails(
      NOTIF_CHANNEL_ID,
      NOTIF_CHANNEL_NAME,
      icon: 'ic_bg_service_small',
      ongoing: true,
    ));

    _flutterLocalNotificationsPlugin.show(id, title, body, notifDetails,
        payload: payload);
  }

  // close a specific channel notification
  static Future cancel(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  // close all the notifications available
  static Future cancelAll() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
