import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Initialize
  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Request permissions for iOS
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notifications.initialize(settings);
  }

  // SCHEDULING FUNCTION
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String soundType, // 'normal' or 'loud'
  }) async {
    // Define Channel based on user selection
    String channelId =
        soundType == 'loud' ? 'loud_channel_id' : 'normal_channel_id';
    String channelName = soundType == 'loud' ? 'Loud Alerts' : 'Normal Alerts';
    String soundFile = soundType == 'loud' ? 'loud_sound' : 'normal_sound';

    // Android Detail
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.max,
      priority: Priority.high,
      sound:
          RawResourceAndroidNotificationSound(soundFile), // Plays from /res/raw
      playSound: true,
    );

    // iOS Detail
    DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      sound: '$soundFile.mp3', // Plays from Bundle
      presentSound: true,
    );

    NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents:
          DateTimeComponents.time, // Repeats daily at this time
    );
  }
}
