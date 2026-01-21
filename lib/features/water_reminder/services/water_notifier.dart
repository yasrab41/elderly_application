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

  // --- FIX: Added 'anchorTime' parameter ---
  Future<void> updateWaterSettings({
    required double intervalMinutes,
    required String activeStart,
    required String activeEnd,
    required String sound,
    required bool vibration,
    required String anchorTime, // <--- NEW PARAMETER
  }) async {
    final newSettings = state.settings.copyWith(
      intervalMinutes: intervalMinutes.toInt(),
      // Gate: Active Hours
      startTime: activeStart,
      endTime: activeEnd,
      // Phase: Start Now / Custom Time
      anchorTime: anchorTime,
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

    // 2. Define Gates (Active Hours Window)
    final gateStart = DateTime(now.year, now.month, now.day,
        settings.startTOD.hour, settings.startTOD.minute);

    final gateEnd = DateTime(now.year, now.month, now.day, settings.endTOD.hour,
        settings.endTOD.minute);

    // 3. Define Anchor (The "Start Now" Phase)
    final anchorTOD = settings.anchorTOD;
    final anchorDate = DateTime(
        now.year, now.month, now.day, anchorTOD.hour, anchorTOD.minute);

    final Duration step = Duration(minutes: settings.intervalMinutes);

    // 4. Align currentSlot to Anchor
    DateTime currentSlot = anchorDate;

    // If anchor is in the past, fast forward to the next future slot
    // while maintaining the phase.
    if (currentSlot.isBefore(now)) {
      while (currentSlot.isBefore(now)) {
        currentSlot = currentSlot.add(step);
      }
    }

    int notificationId = 2000;

    // 5. Scheduling Loop
    while (notificationId < 2100) {
      // Stop if we pass the end of the Active Hours (Gate End)
      if (currentSlot.isAfter(gateEnd)) {
        break;
      }

      // Check Gate Validity: Is it AFTER Gate Start?
      // (We already checked Gate End in the break condition)
      bool isAfterStart = currentSlot.isAtSameMomentAs(gateStart) ||
          currentSlot.isAfter(gateStart);

      // Safety: Ensure it's in the future
      bool isFuture = currentSlot.isAfter(now);

      if (isAfterStart && isFuture) {
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
