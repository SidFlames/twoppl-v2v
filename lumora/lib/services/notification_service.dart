import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  StreamSubscription<QuerySnapshot>? _emergencySubscription;
  bool _isListeningToFirestore = false;

  static const String channelId = 'safesphere_alerts';
  static const String channelName = 'SafeSphere Emergency Alerts';
  static const String channelDescription = 'Notifications for active SOS and safety alerts';

  Future<void> initialize(BuildContext context) async {
    // 1. Request Notification Permissions
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Initialize Local Notifications
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (details) {
        _handleNotificationTap(context, details.payload);
      },
    );

    // Create high importance Android notification channel
    const androidChannel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // 3. Configure FCM Callbacks (Foreground Listener)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        _showLocalNotification(
          title: notification.title ?? 'Emergency Alert',
          body: notification.body ?? 'A contact has triggered an SOS.',
          payload: message.data['emergencyId'],
        );
      }
    });

    // Configure Background/Terminated Tap Handlers
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(context, message.data['emergencyId']);
    });

    // 4. Start Firestore Live Sync Listener (Bulletproof Hackathon Hack)
    // Listens to Firestore 'emergencies' collection directly to bypass FCM configuration issues.
    startFirestoreEmergencyListener(context);
  }

  void startFirestoreEmergencyListener(BuildContext context) {
    if (_isListeningToFirestore) return;
    _isListeningToFirestore = true;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Listen only to active emergencies created in the last 10 minutes to prevent old alert spam on startup
    final now = DateTime.now();
    final cutoffTime = now.subtract(const Duration(minutes: 10));

    _emergencySubscription = FirebaseFirestore.instance
        .collection('emergencies')
        .where('status', isEqualTo: 'active')
        .where('createdAt', isGreaterThan: Timestamp.fromDate(cutoffTime))
        .snapshots()
        .listen((snapshot) async {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data == null) continue;

          final String emergencyId = change.doc.id;
          final String userId = data['userId'] ?? '';
          final String userName = data['userName'] ?? 'Someone in your Circle';
          final String triggerType = data['trigger'] ?? 'manual';

          // Don't trigger notification for the user's own emergency
          if (userId != currentUser.uid) {
            _showLocalNotification(
              title: '🚨 SafeSphere SOS Alert!',
              body: '$userName triggered a voice/safety SOS. Tap to track.',
              payload: emergencyId,
            );

            // Pop up a real-time dialog if the app is open in foreground
            _showEmergencyPopup(context, userName, triggerType, emergencyId);
          }
        }
      }
    });
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotifications.show(
      id: math.Random().nextInt(100000),
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  void _handleNotificationTap(BuildContext context, String? emergencyId) {
    if (emergencyId == null) return;
    
    // In production, navigate to active emergency monitoring screen.
    // For demo, show SnackBar or show dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing live tracking for emergency: $emergencyId'),
        backgroundColor: const Color(0xFFBA1A1A),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _showEmergencyPopup(
    BuildContext context,
    String userName,
    String triggerType,
    String emergencyId,
  ) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFBA1A1A), size: 28),
              SizedBox(width: 10),
              Text(
                'SOS Triggered!',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFBA1A1A)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$userName has triggered their emergency distress signal.',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text('Trigger Source: ${triggerType.toUpperCase()}'),
              Text('Emergency ID: $emergencyId'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Dismiss', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003D9B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _handleNotificationTap(context, emergencyId);
              },
              child: const Text('Track Location'),
            ),
          ],
        );
      },
    );
  }

  void dispose() {
    _emergencySubscription?.cancel();
    _isListeningToFirestore = false;
  }
}
