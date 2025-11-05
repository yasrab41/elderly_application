import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart'; // This import is likely not needed
import 'dart:math';

import '../data/models/medicine_model.dart';
import '../data/datasources/database_service.dart';
import '../data/datasources/notification_service.dart';

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

  Future<void> loadReminders() async {
    state = await _dbService.readAllReminders();
    _isInitialLoadComplete = true;
  }

  // --- ADD REMINDER (MODIFIED) ---
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
      times: times,
      startDate: startDate,
      endDate: endDate,
      isActive: true,
    );

    // We MUST save to DB first to get an ID
    final savedReminder = await _dbService.create(newReminder);

    // Now schedule notifications using the reminder WITH an ID
    await _notificationService.scheduleMedicineReminders(savedReminder);

    state = await _dbService.readAllReminders();
  }

  // --- TOGGLE REMINDER (MODIFIED) ---
  Future<void> toggleReminder(MedicineReminder reminder) async {
    final updatedReminder = reminder.copyWith(isActive: !reminder.isActive);
    await _dbService.update(updatedReminder);

    if (updatedReminder.isActive) {
      // Re-schedule all associated notifications
      await _notificationService.scheduleMedicineReminders(updatedReminder);
    } else {
      // Cancel all associated notifications
      await _notificationService.cancelMedicineReminders(updatedReminder);
    }

    state = [
      for (final item in state)
        if (item.id == updatedReminder.id) updatedReminder else item,
    ];
  }

  // --- DELETE REMINDER (MODIFIED) ---
  Future<void> deleteReminder(MedicineReminder reminder) async {
    // First, cancel all notifications
    await _notificationService.cancelMedicineReminders(reminder);

    // Then, delete from database
    await _dbService.delete(reminder.id!);

    state = state.where((item) => item.id != reminder.id).toList();
  }

  // --- NEW GETTER FOR "TODAY'S SCHEDULE" ---
  List<MedicineReminder> get todaysReminders {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return state.where((reminder) {
      // Check if reminder is active and today is within the start/end date range
      // We add one day to endDate to make the range inclusive
      final endDateInclusive = reminder.endDate.add(const Duration(days: 1));
      return reminder.isActive &&
          (today.isAtSameMomentAs(reminder.startDate) ||
              today.isAfter(reminder.startDate)) &&
          (today.isBefore(endDateInclusive));
    }).toList();
  }

  // --- NEW HELPER FOR "TAKE NOW" BUTTON ---
  Future<void> markAsTaken(MedicineReminder reminder, String time) async {
    // This is where you would build logic to log the medication.
    // For now, we can just print a debug message.
    debugPrint("User marked '${reminder.name}' at $time as TAKEN.");
    // You could also cancel just this one notification for today.
  }
}

// Global provider for accessing the state notifier
final remindersProvider =
    StateNotifierProvider<ReminderStateNotifier, List<MedicineReminder>>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return ReminderStateNotifier(service);
});
