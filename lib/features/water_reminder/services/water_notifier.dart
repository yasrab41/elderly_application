import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Imports
import '../../authentication/services/auth_service.dart';
import '../../medicine_reminders/data/datasources/database_service.dart';
import '../../medicine_reminders/data/datasources/notification_service.dart';
import '../data/models/water_models.dart'; // Centralized models

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

  Future<void> updateSettings(WaterSettings newSettings) async {
    await _db.saveWaterSettings(newSettings);
    state = state.copyWith(settings: newSettings);
    scheduleWaterReminders(newSettings);
  }

  Future<void> scheduleWaterReminders(WaterSettings settings) async {
    // Cancel IDs 2000-2050
    for (int i = 2000; i < 2050; i++) {
      await _notificationService.notificationsPlugin.cancel(i);
    }

    if (!settings.isEnabled) return;

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, settings.startTOD.hour,
        settings.startTOD.minute);
    final end = DateTime(now.year, now.month, now.day, settings.endTOD.hour,
        settings.endTOD.minute);

    DateTime currentSlot = start;
    int notificationId = 2000;

    while (currentSlot.isBefore(end)) {
      if (currentSlot.isAfter(now)) {
        // Pass the soundType and vibration from settings to your scheduler
        await _notificationService.scheduleDailyDose(
          notificationId: notificationId,
          name: "Hydration Time",
          dosage: "Drink some water!",
          time: TimeOfDay.fromDateTime(currentSlot),
          // Ensure your scheduleDailyDose method is updated to accept these:
          // soundType: settings.soundType,
          // vibration: settings.isVibration,
        );
      }
      currentSlot = currentSlot.add(Duration(hours: settings.intervalHours));
      notificationId++;
    }
  }
}

final waterProvider = StateNotifierProvider<WaterNotifier, WaterState>((ref) {
  final user = ref.watch(authNotifierProvider);
  final userId = user?.uid ?? '';
  final notificationService = NotificationService();
  return WaterNotifier(DatabaseService.instance, notificationService, userId);
});
