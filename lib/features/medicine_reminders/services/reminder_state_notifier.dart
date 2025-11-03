import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
// Note: 'flutter_riverpod/legacy.dart' is generally not needed if you use 'flutter_riverpod.dart'
// import 'package:flutter_riverpod/legacy.dart';
import 'dart:math';

// Correct imports based on your file structure
import '../data/models/medicine_model.dart';
import '../data/datasources/database_service.dart';
import '../data/datasources/notification_service.dart';

// Global provider for the Notification Service instance
final notificationServiceProvider = Provider((ref) => NotificationService());

// This is the Riverpod StateNotifier, managing the list of reminders.
class ReminderStateNotifier extends StateNotifier<List<MedicineReminder>> {
  // This is the correct declaration for the dependency
  final NotificationService _notificationService;

  // This is the correct constructor syntax you fixed
  ReminderStateNotifier(this._notificationService) : super([]) {
    loadReminders();
  }

  final _dbService = DatabaseService.instance;

  // This is your correct implementation for the loading flag
  bool _isInitialLoadComplete = false;
  bool get isInitialLoadComplete => _isInitialLoadComplete;

  Future<void> loadReminders() async {
    // This correctly uses the 'state' property
    state = await _dbService.readAllReminders();
    _isInitialLoadComplete = true;
  }

  // --- ADD REMINDER ---
  Future<void> addReminder({
    required String name,
    required String dosage,
    required TimeOfDay time,
  }) async {
    final now = DateTime.now();
    final reminderTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    final newReminder = MedicineReminder(
      name: name,
      dosage: dosage,
      time: reminderTime,
      notificationId: Random().nextInt(10000000),
      isActive: true, // 🟢 IMPORTANT: Ensure new reminders are active
    );

    final savedReminder = await _dbService.create(newReminder);
    await _notificationService.scheduleDailyReminder(savedReminder);

    // This is your fix to reload the list, which ensures the UI updates
    state = await _dbService.readAllReminders();
  }

  // --- TOGGLE REMINDER ---
  Future<void> toggleReminder(MedicineReminder reminder) async {
    final updatedReminder = reminder.copyWith(isActive: !reminder.isActive);

    await _dbService.update(updatedReminder);

    if (updatedReminder.isActive) {
      await _notificationService.scheduleDailyReminder(updatedReminder);
    } else {
      await _notificationService.cancelReminder(updatedReminder.notificationId);
    }

    // This logic correctly updates the state immutably
    state = [
      for (final item in state)
        if (item.id == updatedReminder.id) updatedReminder else item,
    ];
  }

  // --- DELETE REMINDER ---
  Future<void> deleteReminder(int id) async {
    final reminderToDelete = state.firstWhere((r) => r.id == id);

    await _notificationService.cancelReminder(reminderToDelete.notificationId);

    await _dbService.delete(id);

    // This logic correctly updates the state immutably
    state = state.where((item) => item.id != id).toList();
  }
}

// Global provider for accessing the state notifier
final remindersProvider =
    StateNotifierProvider<ReminderStateNotifier, List<MedicineReminder>>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return ReminderStateNotifier(service);
});
