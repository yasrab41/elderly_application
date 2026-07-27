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

  // --- FIX: shared ID namespace ---
  // Offset keeps medicine reminder notification IDs from colliding with the
  // Water Reminder module, which reserves IDs 2000-2099. Any reminder with
  // id >= 20 would previously have produced an ID inside that range
  // (id * 100), silently overwriting or being overwritten by a hydration
  // reminder's scheduled notification.
  static const int idOffset = 10000;

  /// Single source of truth for computing a medicine dose's notification ID.
  /// Used both when scheduling and when cancelling, so the two can never
  /// drift out of sync.
  static int notificationIdFor(int reminderId, int timeIndex) {
    return idOffset + (reminderId * 100) + timeIndex;
  }

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
        'medicine_channel_loud_v3', // 🔴 CHANGED ID to force update
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
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // --- FIX: roll forward instead of skipping ---
    // If this dose's time has already passed today, move the anchor to
    // tomorrow. Combined with matchDateTimeComponents below, this means the
    // very first firing may be tomorrow instead of today, but the alarm is
    // still established now — it no longer depends on the app being
    // reopened at some later point to "catch up".
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Logic to select Channel ID and Sound File
    String channelId = soundType == 'loud'
        ? 'medicine_channel_loud_v3'
        : 'medicine_channel_normal';

    String soundFile = soundType == 'loud' ? 'medicine_voice' : 'normal_sound';

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      soundType == 'loud' ? 'Medicine (Voice)' : 'Medicine Reminders (Normal)',
      channelDescription: 'Daily reminder for taking medicine.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      // Android sound resource (no extension)
      sound: RawResourceAndroidNotificationSound(soundFile),
      enableVibration: vibration,
      vibrationPattern:
          vibration ? Int64List.fromList([0, 500, 200, 500, 200, 1000]) : null,
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
      // --- FIX: makes the alarm repeat daily at this time-of-day,  ---
      // --- independent of the app ever being reopened.            ---
      matchDateTimeComponents: DateTimeComponents.time,
    );
    debugPrint('Scheduled ($soundType) for $name at $scheduledDate (daily)');
  }

  Future<void> cancelMedicineReminders(MedicineReminder reminder) async {
    if (reminder.id == null) return;
    for (int i = 0; i < reminder.times.length; i++) {
      final notificationId = notificationIdFor(reminder.id!, i);
      await notificationsPlugin.cancel(notificationId);
    }
  }

  Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
  }
}
