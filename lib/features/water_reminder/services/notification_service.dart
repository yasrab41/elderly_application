import 'dart:typed_data'; // Needed for Int64List
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart'; // Add this package if missing, or use standard timezone
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Initialize Time Zones (COPIED FROM MEDICINE CODE)
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // 2. Setup Settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    // 3. Initialize Plugin
    await notificationsPlugin.initialize(settings,
        onDidReceiveNotificationResponse: (details) {
      debugPrint('Water Notification tapped: ${details.payload}');
    });

    // 4. Android Specific Setup (CRITICAL FIXES HERE)
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      // FIX A: Request permissions explicitly
      await androidImplementation.requestNotificationsPermission();
      await androidImplementation.requestExactAlarmsPermission();

      // FIX B: Create the Channels EXPLICITLY before scheduling
      // We create two channels: one for Normal, one for Loud.

      // Channel 1: Normal
      const AndroidNotificationChannel normalChannel =
          AndroidNotificationChannel(
        'normal_water_channel_v1', // Unique ID
        'Normal Water Alerts',
        description: 'Gentle water reminders',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('normal_sound'),
      );
      await androidImplementation.createNotificationChannel(normalChannel);

      // Channel 2: Loud
      const AndroidNotificationChannel loudChannel = AndroidNotificationChannel(
        'loud_water_channel_v1', // Unique ID
        'Loud Water Alerts',
        description: 'Loud water reminders',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('loud_sound'),
        enableVibration: true,
      );
      await androidImplementation.createNotificationChannel(loudChannel);
    }
  }

  Future<void> scheduleDailyDose({
    required int notificationId,
    required String name,
    required String dosage,
    required TimeOfDay time,
    String soundType = 'normal',
    bool vibration = true,
  }) async {
    // 1. Select the correct Channel ID based on user choice
    // Note: These IDs must match what we created in init()
    String channelId = soundType == 'loud'
        ? 'loud_water_channel_v1'
        : 'normal_water_channel_v1';

    String channelName =
        soundType == 'loud' ? 'Loud Water Alerts' : 'Normal Water Alerts';

    // 2. Select the sound file
    // Note: Do not include '.mp3' for Android here
    String soundFile = soundType == 'loud' ? 'loud_sound' : 'normal_sound';

    // 3. Android Details
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      // We must specify the sound here again to match the channel
      sound: RawResourceAndroidNotificationSound(soundFile),
      enableVibration: vibration,
      vibrationPattern:
          vibration ? Int64List.fromList([0, 500, 200, 500]) : null,
    );

    // 4. iOS Details
    DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentSound: true,
      // iOS requires the file extension
      sound: '$soundFile.mp3',
    );

    NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // 5. Calculate Time
    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // 6. Schedule
    // We use zonedSchedule with exactAllowWhileIdle (Same as your Medicine app)
    await notificationsPlugin.zonedSchedule(
      notificationId,
      name,
      dosage,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

      matchDateTimeComponents: DateTimeComponents.time, // Repeats daily
    );

    debugPrint(
        "Scheduled Water ($soundType) for: $scheduledDate on channel: $channelId");
  }
}
