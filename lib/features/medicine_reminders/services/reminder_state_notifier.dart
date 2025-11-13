import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import '../data/models/medicine_model.dart';
import '../data/datasources/database_service.dart';
import '../data/datasources/notification_service.dart';
// 1. Import the new AuthService
import '../../authentication/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Ensure Firebase User is imported

// (MedicineDose class remains the same)
class MedicineDose {
  final MedicineReminder reminder;
  final String timeStr;
  final TimeOfDay timeOfDay;

  MedicineDose({
    required this.reminder,
    required this.timeStr,
  }) : timeOfDay = TimeOfDay(
          hour: int.parse(timeStr.split(':')[0]),
          minute: int.parse(timeStr.split(':')[1]),
        );
}

final notificationServiceProvider = Provider((ref) => NotificationService());

// This is the Riverpod StateNotifier, managing the list of reminders.
class ReminderStateNotifier extends StateNotifier<List<MedicineReminder>> {
  final NotificationService _notificationService;
  final String _userId; // 2. Add userId
  final Ref _ref; // 3. Add Ref

  bool _isInitialLoadComplete = false;
  bool get isInitialLoadComplete => _isInitialLoadComplete;

  // 4. Update constructor
  ReminderStateNotifier(this._notificationService, this._userId, this._ref)
      : super([]) {
    if (_userId.isNotEmpty) {
      loadRemindersAndSchedule();
    }
  }

  final _dbService = DatabaseService.instance;

  DateTime _normalizeDate(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  Future<void> loadRemindersAndSchedule() async {
    if (_userId.isEmpty) return; // Don't load if no user
    // 5. Pass userId to DB call
    state = await _dbService.readAllReminders(_userId);
    _isInitialLoadComplete = true;

    await _notificationService.cancelAllNotifications();
    final dosesForToday = todaysDoses;

    for (final dose in dosesForToday) {
      final reminderId = dose.reminder.id!;
      final timeIndex = dose.reminder.times.indexOf(dose.timeStr);
      final notificationId = (reminderId * 100) + timeIndex;

      await _notificationService.scheduleDailyDose(
        notificationId: notificationId,
        name: dose.reminder.name,
        dosage: dose.reminder.dosage,
        time: dose.timeOfDay,
      );
    }
  }

  Future<void> addReminder({
    required String name,
    required String dosage,
    required List<String> times,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final newReminder = MedicineReminder(
      name: name,
      dosage: dosage,
      times: times,
      startDate: startDate,
      endDate: endDate,
      isActive: true,
    );
    // 6. Pass userId to DB call
    await _dbService.create(newReminder, _userId);

    await loadRemindersAndSchedule();
  }

  Future<void> updateReminder(MedicineReminder updatedReminder) async {
    final originalReminder =
        state.firstWhere((r) => r.id == updatedReminder.id);
    await _notificationService.cancelMedicineReminders(originalReminder);

    // 7. Pass userId to DB call
    await _dbService.update(updatedReminder, _userId);

    await loadRemindersAndSchedule();
  }

  Future<void> toggleReminder(MedicineReminder reminder) async {
    final updatedReminder = reminder.copyWith(isActive: !reminder.isActive);
    // 8. Pass userId to DB call
    await _dbService.update(updatedReminder, _userId);

    await loadRemindersAndSchedule();
  }

  Future<void> deleteReminder(MedicineReminder reminder) async {
    await _notificationService.cancelMedicineReminders(reminder);
    // 9. Pass userId to DB call
    await _dbService.delete(reminder.id!, _userId);

    state = state.where((item) => item.id != reminder.id).toList();
  }

  // (todaysDoses getter remains the same, it's correct)
  List<MedicineDose> get todaysDoses {
    final now = DateTime.now();
    final today = _normalizeDate(now);

    final List<MedicineDose> allDoses = [];

    // 1. Get all active medicines for today
    final activeReminders = state.where((reminder) {
      final normalizedStart = _normalizeDate(reminder.startDate);
      final normalizedEnd = _normalizeDate(reminder.endDate);

      final isAfterOrSameAsStart = today.compareTo(normalizedStart) >= 0;
      final isBeforeOrSameAsEnd = today.compareTo(normalizedEnd) <= 0;
      final isInDateRange = isAfterOrSameAsStart && isBeforeOrSameAsEnd;

      return reminder.isActive && isInDateRange;
    }).toList();

    // 2. Create a flat list of all individual doses
    for (final reminder in activeReminders) {
      for (final timeStr in reminder.times) {
        allDoses.add(MedicineDose(reminder: reminder, timeStr: timeStr));
      }
    }

    // 3. Sort the final list by time
    allDoses.sort((a, b) {
      final aTime = a.timeOfDay.hour * 60 + a.timeOfDay.minute;
      final bTime = b.timeOfDay.hour * 60 + b.timeOfDay.minute;
      return aTime.compareTo(bTime);
    });

    return allDoses;
  }
}

// 10. 🛑 MODIFIED PROVIDER - FIXED NULL ERROR
final remindersProvider =
    StateNotifierProvider<ReminderStateNotifier, List<MedicineReminder>>((ref) {
  // Watch the auth state (User?)
  final User? user = ref.watch(authNotifierProvider);
  // FIX: Use safe access on the nullable user object (user?)
  final userId = user?.uid ?? ''; // Get the user ID or empty string

  final service = ref.watch(notificationServiceProvider);
  // Pass the userId to the notifier
  return ReminderStateNotifier(service, userId, ref);
});
