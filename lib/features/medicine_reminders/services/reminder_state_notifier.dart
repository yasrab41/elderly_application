import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/models/medicine_model.dart';
import '../data/datasources/database_service.dart';
import '../data/datasources/notification_service.dart';

// --- MODEL CLASS ---
// A helper class to represent a single dose at a specific time
class MedicineDose {
  final MedicineReminder reminder;
  final String timeStr; // e.g., "08:00"
  final TimeOfDay timeOfDay;

  MedicineDose({
    required this.reminder,
    required this.timeStr,
  }) : timeOfDay = TimeOfDay(
          hour: int.parse(timeStr.split(':')[0]),
          minute: int.parse(timeStr.split(':')[1]),
        );
}

// Global provider for the Notification Service instance
final notificationServiceProvider = Provider((ref) => NotificationService());

// This is the Riverpod StateNotifier, managing the list of reminders.
class ReminderStateNotifier extends StateNotifier<List<MedicineReminder>> {
  final NotificationService _notificationService;

  bool _isInitialLoadComplete = false;
  bool get isInitialLoadComplete => _isInitialLoadComplete;

  ReminderStateNotifier(this._notificationService) : super([]) {
    loadReminders();
  }

  final _dbService = DatabaseService.instance;

  // Utility to strip time for pure date comparison (Year/Month/Day only)
  DateTime _normalizeDate(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  Future<void> loadReminders() async {
    state = await _dbService.readAllReminders();
    _isInitialLoadComplete = true;
  }

  // --- ADD REMINDER ---
  Future<void> addReminder({
    required String name,
    required String dosage,
    required List<String> times, // Now a list of strings
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final newReminder = MedicineReminder(
      name: name,
      dosage: dosage,
      times: times, // Use the new list
      startDate: startDate, // Use the new date
      endDate: endDate, // Use the new date
      isActive: true,
    );

    // We MUST save to DB first to get an ID
    final savedReminder = await _dbService.create(newReminder);

    // Now schedule notifications using the reminder WITH an ID
    await _notificationService.scheduleMedicineReminders(savedReminder);

    state = await _dbService.readAllReminders();
  }

  // --- TOGGLE REMINDER ---
  Future<void> toggleReminder(MedicineReminder reminder) async {
    final updatedReminder = reminder.copyWith(isActive: !reminder.isActive);

    await _dbService.update(updatedReminder);

    if (updatedReminder.isActive) {
      await _notificationService.scheduleMedicineReminders(updatedReminder);
    } else {
      await _notificationService.cancelMedicineReminders(reminder);
    }

    state = [
      for (final item in state)
        if (item.id == updatedReminder.id) updatedReminder else item,
    ];
  }

  // --- DELETE REMINDER ---
  Future<void> deleteReminder(MedicineReminder reminder) async {
    await _notificationService.cancelMedicineReminders(reminder);
    await _dbService.delete(reminder.id!);
    state = state.where((item) => item.id != reminder.id).toList();
  }

  // 🔑 VERIFIED GETTER NAME: todaysDoses
  List<MedicineDose> get todaysDoses {
    final now = DateTime.now();
    // Normalize today's date to midnight for comparison
    final today = _normalizeDate(now);

    final List<MedicineDose> allDoses = [];

    // 1. Get all active medicines for today
    final activeReminders = state.where((reminder) {
      // Normalize reminder dates for pure date comparison
      final normalizedStart = _normalizeDate(reminder.startDate);
      final normalizedEnd = _normalizeDate(reminder.endDate);

      // CRITICAL FIX: Use compareTo for robust date-only comparison.
      // today is after or same as start (today >= start)
      final isAfterOrSameAsStart = today.compareTo(normalizedStart) >= 0;
      // today is before or same as end (today <= end)
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

// Global provider for accessing the state notifier
final remindersProvider =
    StateNotifierProvider<ReminderStateNotifier, List<MedicineReminder>>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return ReminderStateNotifier(service);
});
