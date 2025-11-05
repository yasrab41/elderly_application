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

  // --- Core Scheduling Function (HEAVILY MODIFIED) ---

  // This function will now schedule ALL reminders for a medicine
  Future<void> scheduleMedicineReminders(MedicineReminder reminder) async {
    if (!reminder.isActive) return;

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

    // Loop through each time string (e.g., "08:00", "20:00")
    for (int i = 0; i < reminder.times.length; i++) {
      final timeParts = reminder.times[i].split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      // Create a unique notification ID for each time.
      // Example: Reminder ID 7, time index 0 -> ID 700
      // Example: Reminder ID 7, time index 1 -> ID 701
      // Note: This assumes reminder.id is not null!
      final notificationId = (reminder.id! * 100) + i;

      // Get the first occurrence of this time
      tz.TZDateTime scheduledDate = _nextInstanceOfTime(hour, minute);

      // Only schedule if the first occurrence is before the reminder's End Date
      if (scheduledDate
          .isBefore(reminder.endDate.add(const Duration(days: 1)))) {
        // Check if the scheduled date is also after the Start Date
        // If it's not, move to the first valid day.
        if (scheduledDate.isBefore(reminder.startDate)) {
          scheduledDate = tz.TZDateTime(tz.local, reminder.startDate.year,
              reminder.startDate.month, reminder.startDate.day, hour, minute);

          // If this new date is still in the past (e.g., start date is today but time has passed), move to tomorrow
          if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
            scheduledDate = scheduledDate.add(const Duration(days: 1));
          }
        }

        // Final check to ensure we don't schedule past the end date
        if (scheduledDate
            .isBefore(reminder.endDate.add(const Duration(days: 1)))) {
          await notificationsPlugin.zonedSchedule(
            notificationId,
            'Time to take ${reminder.name}!',
            'Dosage: ${reminder.dosage}. Don\'t forget!',
            scheduledDate,
            notificationDetails,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

            // Using the parameter name that worked for your local setup

            matchDateTimeComponents:
                DateTimeComponents.time, // This makes it repeat daily
            payload: '${reminder.id}:$i', // Include index in payload
          );
          debugPrint(
              'Scheduled ${reminder.name} (ID $notificationId) for ${scheduledDate.toString()}');
        }
      }
    }
  }

  // This helper finds the next valid occurrence of a time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  // --- Cancellation Function (HEAVILY MODIFIED) ---
  // We must now cancel ALL notifications associated with a reminder
  Future<void> cancelMedicineReminders(MedicineReminder reminder) async {
    // Loop through the known number of times and cancel each derived ID
    // We need a null check for reminder.id, as it might be called on a non-saved reminder
    if (reminder.id == null) return;

    for (int i = 0; i < reminder.times.length; i++) {
      final notificationId = (reminder.id! * 100) + i;
      await notificationsPlugin.cancel(notificationId);
      debugPrint('Canceled notification ID: $notificationId');
    }
  }
}
