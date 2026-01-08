import 'package:elderly_prototype_app/features/water_reminder/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../authentication/services/auth_service.dart';
import '../../medicine_reminders/data/datasources/database_service.dart';

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

  String _formatCurrentTime() => DateFormat('HH:mm').format(DateTime.now());

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

  Future<void> updateWaterSettings({
    required String startMode,
    required String customStartTime,
    required double intervalMinutes,
    required String activeStart,
    required String activeEnd,
    required String sound,
    required bool vibration,
  }) async {
    final newSettings = state.settings.copyWith(
      // FIX: Store exact minutes (no rounding to hours)
      intervalMinutes: intervalMinutes.toInt(),
      startTime: activeStart,
      // startTime: startMode == 'now' ? _formatCurrentTime() : customStartTime,
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
    // 1. Cancel IDs 2000-2050
    for (int i = 2000; i < 2050; i++) {
      await _notificationService.notificationsPlugin.cancel(i);
    }

    if (!settings.isEnabled) return;

    final now = DateTime.now();

    // 2. Setup timing logic
    final start = DateTime(now.year, now.month, now.day, settings.startTOD.hour,
        settings.startTOD.minute);
    final end = DateTime(now.year, now.month, now.day, settings.endTOD.hour,
        settings.endTOD.minute);

    DateTime currentSlot = start;
    int notificationId = 2000;

    // FIX: Use minutes from model
    final Duration step = Duration(minutes: settings.intervalMinutes);

    // 3. Scheduling Loop
    while (currentSlot.isBefore(end)) {
      if (currentSlot.isAfter(now)) {
        // FIX: UNCOMMENTED THE NOTIFICATION LOGIC
        await _notificationService.scheduleDailyDose(
          notificationId: notificationId,
          name: "Hydration Time",
          dosage: "Time to drink water!",
          time: TimeOfDay.fromDateTime(currentSlot),
          soundType: settings.soundType,
          vibration: settings.isVibration,
        );
      }
      currentSlot = currentSlot.add(step);
      notificationId++;

      if (notificationId > 2050) break;
    }
  }
}

final waterProvider = StateNotifierProvider<WaterNotifier, WaterState>((ref) {
  final user = ref.watch(authNotifierProvider);
  final userId = user?.uid ?? '';
  final notificationService = NotificationService();
  return WaterNotifier(DatabaseService.instance, notificationService, userId);
});
