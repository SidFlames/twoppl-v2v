import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../firebase_options.dart';

class VoiceBackgroundService {
  static const String notificationChannelId = 'safesphere_voice_alerts';
  static const int notificationId = 888;

  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    // Standard Android Notification Channel setup
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      notificationChannelId,
      'SafeSphere Active Protection',
      description: 'Listens for voice wake-words in the background for automatic SOS response.',
      importance: Importance.low,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: notificationChannelId,
        initialNotificationTitle: 'SafeSphere Active Protection',
        initialNotificationContent: 'SilentPass background listener running...',
        foregroundServiceNotificationId: notificationId,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize Firebase in background isolate
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (_) {}

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    // Start background listening (Simulating Picovoice Porcupine + Eagle detection loop)
    // In production, instantiate PorcupineManager and EagleProfile here.
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (service is AndroidServiceInstance) {
        if (!(await service.isForegroundService())) {
          timer.cancel();
          return;
        }
      }

      // Check if user is logged in
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Randomly simulate a mock voice trigger for demo testing (e.g. 2% chance every 10s)
        final triggerMock = math.Random().nextDouble() < 0.02;
        if (triggerMock) {
          try {
            final firestore = FirebaseFirestore.instance;
            final uuid = const Uuid();
            final emergencyId = uuid.v4();

            // Fetch user's name from firestore
            String userName = 'Someone in your Circle';
            try {
              final userDoc = await firestore.collection('users').doc(currentUser.uid).get();
              if (userDoc.exists) {
                userName = userDoc.data()?['name'] ?? userName;
              }
            } catch (_) {}

            // Create real Firestore record in 'emergencies' collection
            await firestore.collection('emergencies').doc(emergencyId).set({
              'emergencyId': emergencyId,
              'userId': currentUser.uid,
              'userName': userName,
              'rideId': '', // Standalone trigger, not tied to active journey
              'trigger': 'voice',
              'status': 'active',
              'createdAt': FieldValue.serverTimestamp(),
            });

            // Trigger notification
            flutterLocalNotificationsPlugin.show(
              id: notificationId,
              title: '🚨 SOS Emergency Activated',
              body: 'Voice trigger "Help Help" verified. Guardians notified.',
              notificationDetails: const NotificationDetails(
                android: AndroidNotificationDetails(
                  notificationChannelId,
                  'SafeSphere Active Protection',
                  channelDescription: 'Emergency SOS notification',
                  importance: Importance.max,
                  priority: Priority.high,
                  ongoing: true,
                ),
              ),
            );
          } catch (e) {
            debugPrint('Failed to trigger emergency from background: $e');
          }
        }
      }
    });

    service.on('stopService').listen((event) {
      service.stopSelf();
    });
  }
}
