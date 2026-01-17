import 'dart:typed_data'; // Needed for Int64List
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/medicine_model.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      await androidImplementation.requestExactAlarmsPermission();

      // --- CREATE TWO CHANNELS (Normal & Loud) ---

      // 1. Normal Channel
      const AndroidNotificationChannel normalChannel =
          AndroidNotificationChannel(
        'medicine_channel_normal', // ID
        'Medicine Reminders (Normal)', // Name
        description: 'Gentle medicine reminders',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('normal_sound'),
      );
      await androidImplementation.createNotificationChannel(normalChannel);

      // 2. Loud Channel (Voice Message)
      const AndroidNotificationChannel loudChannel = AndroidNotificationChannel(
        'medicine_channel_loud_v2', // 🔴 CHANGED ID to force update
        'Medicine Reminders (Voice)',
        description: 'Voice reminder for medicine',
        importance: Importance.max,
        playSound: true,
        // 🔴 CHANGE THIS:
        sound: RawResourceAndroidNotificationSound('medicine_voice'),
        enableVibration: true,
      );
      await androidImplementation.createNotificationChannel(loudChannel);
    }

    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('Notification tapped: ${details.payload}');
      },
    );
  }

  Future<void> scheduleDailyDose({
    required int notificationId,
    required String name,
    required String dosage,
    required TimeOfDay time,
    required String soundType, // Pass sound type
    required bool vibration, // Pass vibration preference
  }) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    final tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isAfter(now)) {
      // Logic to select Channel ID and Sound File
      String channelId = soundType == 'loud'
          ? 'medicine_channel_loud_v2'
          : 'medicine_channel_normal';

      String soundFile =
          soundType == 'loud' ? 'medicine_voice' : 'normal_sound';

      AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        channelId,
        soundType == 'loud'
            ? 'Medicine (Voice)'
            : 'Medicine Reminders (Normal)',
        channelDescription: 'Daily reminder for taking medicine.',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        // Android sound resource (no extension)
        sound: RawResourceAndroidNotificationSound(soundFile),
        enableVibration: vibration,
        vibrationPattern: vibration
            ? Int64List.fromList([0, 500, 200, 500, 200, 1000])
            : null,
      );

      DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentSound: true,
        // iOS sound file (needs extension)
        sound: '$soundFile.mp3',
      );

      NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await notificationsPlugin.zonedSchedule(
        notificationId,
        'Time to take $name!',
        'Dosage: $dosage',
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint('Scheduled ($soundType) for $name at $scheduledDate');
    }
  }

  Future<void> cancelMedicineReminders(MedicineReminder reminder) async {
    if (reminder.id == null) return;
    for (int i = 0; i < reminder.times.length; i++) {
      final notificationId = (reminder.id! * 100) + i;
      await notificationsPlugin.cancel(notificationId);
    }
  }

  Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
  }
}
