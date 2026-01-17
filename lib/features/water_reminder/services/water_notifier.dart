import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../authentication/services/auth_service.dart';
import '../../medicine_reminders/data/datasources/database_service.dart';
import 'notification_service.dart';
import '../data/models/water_models.dart';

class WaterNotifier extends StateNotifier<WaterState> {
  final DatabaseService _db;
  final NotificationService _notificationService;
  final String _userId;

  WaterNotifier(this._db, this._notificationService, this._userId)
      : super(WaterState(
            todayLogs: [],
            settings: WaterSettings(userId: _userId),
            isLoading: true)) {
    if (_userId.isNotEmpty) {
      loadData();
    }
  }

  Future<void> loadData() async {
    final settings =
        await _db.getWaterSettings(_userId) ?? WaterSettings(userId: _userId);
    final logs = await _db.getTodayWaterLogs(_userId);
    final currentTotal = logs.fold(0, (sum, log) => sum + log.amount);

    state = WaterState(
      todayLogs: logs,
      settings: settings,
      currentIntake: currentTotal,
      isLoading: false,
    );

    scheduleWaterReminders(settings);
  }

  Future<void> addWater(int amount) async {
    final newLog = WaterLog(
      userId: _userId,
      amount: amount,
      timestamp: DateTime.now(),
    );
    await _db.addWaterLog(newLog);
    await loadData();
  }

  Future<void> deleteLog(int id) async {
    await _db.deleteWaterLog(id);
    await loadData();
  }

  // --- FIX: Removed 'startMode' and 'customStartTime' ---
  Future<void> updateWaterSettings({
    required double intervalMinutes,
    required String activeStart,
    required String activeEnd,
    required String sound,
    required bool vibration,
  }) async {
    final newSettings = state.settings.copyWith(
      intervalMinutes: intervalMinutes.toInt(),
      // We accept the calculated string (e.g. "10:05") directly
      startTime: activeStart,
      endTime: activeEnd,
      soundType: sound,
      isVibration: vibration,
      isEnabled: true,
    );

    await _db.saveWaterSettings(newSettings);
    state = state.copyWith(settings: newSettings);
    scheduleWaterReminders(newSettings);
  }

  Future<void> updateSettings(WaterSettings newSettings) async {
    await _db.saveWaterSettings(newSettings);
    state = state.copyWith(settings: newSettings);
    scheduleWaterReminders(newSettings);
  }

  Future<void> scheduleWaterReminders(WaterSettings settings) async {
    // 1. Cancel previous notifications
    for (int i = 2000; i < 2100; i++) {
      await _notificationService.notificationsPlugin.cancel(i);
    }

    if (!settings.isEnabled) return;

    final now = DateTime.now();

    // This 'savedStart' is now correct (It is either Now or Custom Time)
    final savedStart = DateTime(now.year, now.month, now.day,
        settings.startTOD.hour, settings.startTOD.minute);

    final end = DateTime(now.year, now.month, now.day, settings.endTOD.hour,
        settings.endTOD.minute);

    // If the saved start time is in the past (e.g. 8:00 AM), we start counting from Now
    // If it's in the future (e.g. 6:00 PM), we wait for it.
    DateTime baseTime = savedStart.isAfter(now) ? savedStart : now;

    // Exception: If the user explicitly chose "Custom Time" that is in the past,
    // we align the grid to that past time.
    // But for simplicity in this fix, relying on 'savedStart' as the anchor is best.
    // If user selected "Start Now", savedStart is virtually identical to 'now'.

    final Duration step = Duration(minutes: settings.intervalMinutes);

    // Calculate the first notification time.
    // If I click "Start Now" at 14:00 with 1 hour interval,
    // the first notification should be at 15:00.
    DateTime currentSlot;

    if (savedStart.isAfter(now)) {
      // If start time is future, that IS the first slot (or should we wait interval?)
      // Usually, if I set "Start at 14:30", I expect a reminder at 14:30 or 14:30 + interval.
      // Let's assume the first reminder is AT the start time for custom future times.
      currentSlot = savedStart;
    } else {
      // If start time is Now/Past, add one interval.
      // Example: Start Now (14:00) -> First alert 15:00.
      // Example: Start 8:00 (Grid) -> Grid aligns to 8:00, find next slot after now.

      // Recalculate grid based on strict Start Time anchor for consistency
      currentSlot = savedStart;
      while (currentSlot.isBefore(now)) {
        currentSlot = currentSlot.add(step);
      }
    }

    int notificationId = 2000;

    // 4. Scheduling Loop
    while (notificationId < 2100) {
      // Stop if we pass the End Time
      if (currentSlot.hour > end.hour ||
          (currentSlot.hour == end.hour && currentSlot.minute > end.minute)) {
        break;
      }

      if (currentSlot.isAfter(now)) {
        await _notificationService.scheduleDailyDose(
          notificationId: notificationId,
          name: "Hydration Time",
          dosage: "Time to drink water!",
          time: TimeOfDay.fromDateTime(currentSlot),
          soundType: settings.soundType,
          vibration: settings.isVibration,
        );
        notificationId++;
      }

      // Move to next slot
      currentSlot = currentSlot.add(step);
    }
  }
}

// Global Provider Definition
final waterProvider = StateNotifierProvider<WaterNotifier, WaterState>((ref) {
  final user = ref.watch(authNotifierProvider);
  final userId = user?.uid ?? '';
  final notificationService = NotificationService();
  return WaterNotifier(DatabaseService.instance, notificationService, userId);
});
