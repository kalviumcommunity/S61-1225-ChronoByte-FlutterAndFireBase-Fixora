import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    await _requestPermission();
    await _initLocalNotifications();

    // 🔔 Foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        _showLocalNotification(
          notification.title ?? '',
          notification.body ?? '',
        );
      }
    });

    // 🔔 When notification is tapped
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('Notification clicked');
    });

    // 🔑 Token handling
    final token = await _fcm.getToken();
    if (token != null) {
      await _saveToken(token);
      debugPrint('FCM TOKEN: $token');
    }

    _fcm.onTokenRefresh.listen(_saveToken);

    _initialized = true;
  }

  /// 🔐 Android 13+ permission
  Future<void> _requestPermission() async {
    if (Platform.isAndroid) {
      await Permission.notification.request();
    } else if (Platform.isIOS) {
      await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// 🔔 Local notifications + channel
  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    await _local.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    const channel = AndroidNotificationChannel(
      'fixora_channel',
      'Fixora Notifications',
      description: 'Important notifications from Fixora',
      importance: Importance.max,
    );

    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _showLocalNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'fixora_channel',
      'Fixora Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    await _local.show(
      0,
      title,
      body,
      const NotificationDetails(android: androidDetails),
    );
  }

  Future<void> _saveToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({
      'fcmTokens': FieldValue.arrayUnion([token]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
