import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/medicine_model.dart';
// 1. Import the MedicineDose class
import '../../services/reminder_state_notifier.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // (init() method remains exactly the same as your bug-free version)
  Future<void> init() async {
    // 1. Initialize Time Zone data
    tz.initializeTimeZones();

    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // 2. Platform-specific settings
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

    // 3. Request Runtime Permissions & Create Channel
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      // 🟢 FIX: CREATE NOTIFICATION CHANNEL (for sound/visibility)
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'daily_medicine_channel', // Match this ID exactly!
        'Daily Medicine Reminders',
        description:
            'This channel is used for high-priority medicine reminders with sound.',
        importance: Importance.max, // MAX importance ensures sound is used
        playSound: true,
      );

      await androidImplementation.createNotificationChannel(channel);

      await androidImplementation.requestNotificationsPermission();

      await androidImplementation.requestExactAlarmsPermission();
    }

    // 4. Final Initialization
    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('Notification tapped with payload: ${details.payload}');
      },
    );
  }

  // --- 2. 🛑 NEW: scheduleDailyDose ---
  // This function schedules a SINGLE, NON-REPEATING alarm for today
  Future<void> scheduleDailyDose({
    required int notificationId,
    required String name,
    required String dosage,
    required TimeOfDay time,
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

    // Only schedule if the time is in the future (later today)
    if (scheduledDate.isAfter(now)) {
      const androidDetails = AndroidNotificationDetails(
        'daily_medicine_channel',
        'Daily Medicine Reminder',
        channelDescription: 'Daily reminder for taking medicine.',
        importance: Importance.max,
        priority: Priority.high,
      );
      const notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await notificationsPlugin.zonedSchedule(
        notificationId,
        'Time to take $name!',
        'Dosage: $dosage. Don\'t forget!',
        scheduledDate, // This is the exact time today
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint(
          'Scheduled ONE-TIME alarm for $name (ID $notificationId) at $scheduledDate');
    }
  }

  // --- 3. 🛑 MODIFIED: cancelMedicineReminders ---
  // This now just cancels specific IDs, which we still need for deleting/toggling
  Future<void> cancelMedicineReminders(MedicineReminder reminder) async {
    if (reminder.id == null) return;

    for (int i = 0; i < reminder.times.length; i++) {
      final notificationId = (reminder.id! * 100) + i;
      await notificationsPlugin.cancel(notificationId);
      debugPrint('Canceled notification ID: $notificationId');
    }
  }

  // --- 4. 🛑 NEW: cancelAllNotifications ---
  // This is used to clear all alarms when the app starts, before rescheduling
  Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
    debugPrint('Cancelled ALL scheduled notifications.');
  }
}
