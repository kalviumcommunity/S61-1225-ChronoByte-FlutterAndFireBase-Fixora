import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Top-level background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // You can do background processing here if needed
  // For simple use, we don't write to Firestore from background handler
}

class NotificationService {
  NotificationService._privateConstructor();
  static final NotificationService instance = NotificationService._privateConstructor();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    // Request permissions (iOS & Android 13+)
    await _requestPermission();

    // Initialize local notifications
    await _initLocalNotifications();

    // Set background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleMessage(message, foreground: true);
    });

    // When the app is opened from a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle navigation if needed
    });

    // Token handling
    final token = await _fcm.getToken();
    if (token != null) await _saveTokenToFirestore(token);

    _fcm.onTokenRefresh.listen((newToken) async {
      await _saveTokenToFirestore(newToken);
    });

    // React to auth state changes and clean up tokens on sign-out
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user == null) {
        // Optionally remove tokens for signed out state
      } else {
        final currentToken = await _fcm.getToken();
        if (currentToken != null) await _saveTokenToFirestore(currentToken);
      }
    });

    _initialized = true;
  }

  Future<void> _requestPermission() async {
    try {
      if (Platform.isIOS) {
        await _fcm.requestPermission(alert: true, badge: true, sound: true);
      } else if (Platform.isAndroid) {
        // On Android 13+ the system will ask for POST_NOTIFICATIONS permission
        // The plugin doesn't request it automatically; you should request it via
        // permission_handler or platform-specific code. We keep this note here.
      }
    } catch (e) {
      // ignore errors
    }
  }

  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    await _local.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (payload) {
        // handle taps
      },
    );
  }

  Future<void> _handleMessage(RemoteMessage message, {bool foreground = false}) async {
    final notification = message.notification;
    if (notification != null) {
      await _showLocalNotification(notification.title ?? '', notification.body ?? '');
    }
    // Optionally handle data messages
  }

  Future<void> _showLocalNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'fixora_channel',
      'Fixora Notifications',
      channelDescription: 'Important notifications from Fixora',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();

    await _local.show(
      0,
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }

  Future<void> _saveTokenToFirestore(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = FirebaseFirestore.instance.collection('users').doc(user.uid);

    try {
      await doc.set({
        'fcmTokens': FieldValue.arrayUnion([token]),
        'lastFcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // ignore
    }
  }

  Future<void> removeTokenFromFirestore(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    try {
      await doc.update({
        'fcmTokens': FieldValue.arrayRemove([token]),
      });
    } catch (e) {}
  }
}
