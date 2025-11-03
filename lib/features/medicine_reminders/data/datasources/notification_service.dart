import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Corrected relative path to the model based on your structure
import '../models/medicine_model.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Initialize Time Zone data
    tz.initializeTimeZones();

    // ✅ YOUR FIX: The specific method name that works in your environment.
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
      // This MUST be done before notifications are scheduled.
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'daily_medicine_channel', // Match this ID exactly!
        'Daily Medicine Reminders',
        description:
            'This channel is used for high-priority medicine reminders with sound.',
        importance: Importance.max, // MAX importance ensures sound is used
        playSound: true,
      );

      await androidImplementation.createNotificationChannel(channel);

      // For Android 13+ (API 33), request the POST_NOTIFICATIONS permission
      await androidImplementation.requestNotificationsPermission();

      // ✅ YOUR FIX: Request permission for exact alarms to resolve PlatformException
      final bool? granted =
          await androidImplementation.requestExactAlarmsPermission();

      if (granted == true) {
        debugPrint("Exact Alarm Permission GRANTED.");
      } else {
        debugPrint(
            "Exact Alarm Permission DENIED. Reminders may be unreliable.");
      }
    }

    // 4. Final Initialization
    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('Notification tapped with payload: ${details.payload}');
      },
    );
  }

  // Helper function to find the next instance of the target time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  // --- Core Scheduling Function ---

  Future<void> scheduleDailyReminder(MedicineReminder reminder) async {
    if (!reminder.isActive) return;

    final time = reminder.time;
    final scheduledTime = _nextInstanceOfTime(time.hour, time.minute);

    const androidDetails = AndroidNotificationDetails(
      'daily_medicine_channel', // Must match the channel ID created in init()
      'Daily Medicine Reminder',
      channelDescription: 'Daily reminder for taking medicine.',
      importance: Importance.max, // High importance
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await notificationsPlugin.zonedSchedule(
      reminder.notificationId,
      'Time to take ${reminder.name}!',
      'Dosage: ${reminder.dosage}. Don\'t forget!',
      scheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

      // This parameter name is used as it previously worked for your setup
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,

      matchDateTimeComponents: DateTimeComponents.time,
      payload: reminder.id.toString(),
    );
    debugPrint('Scheduled ${reminder.name} for ${scheduledTime.toString()}');
  }

  // --- Cancellation Function ---

  Future<void> cancelReminder(int notificationId) async {
    await notificationsPlugin.cancel(notificationId);
    debugPrint('Canceled notification ID: $notificationId');
  }
}
