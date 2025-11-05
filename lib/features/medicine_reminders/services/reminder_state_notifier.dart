import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:math';

// ---------------------------------------------------------
// FIX 1: Corrected Imports
// Adjust the relative path to jump from 'services' folder to 'data/...'
// Depending on your exact structure, you might only need one '..'
import '../data/models/medicine_model.dart';
import '../data/datasources/database_service.dart';
import '../data/datasources/notification_service.dart';
// ---------------------------------------------------------

// Global provider for the Notification Service instance
final notificationServiceProvider = Provider((ref) => NotificationService());

// This is the Riverpod StateNotifier, managing the list of reminders.
class ReminderStateNotifier extends StateNotifier<List<MedicineReminder>> {
  // FIX 2: Correct declaration of the final variable
  final NotificationService _notificationService;

  // FIX 3: Correct constructor call
  // Pass the dependency (this._notificationService) and the initial state (super([]))
  ReminderStateNotifier(this._notificationService) : super([]) {
    loadReminders();
  }

  final _dbService = DatabaseService.instance;

  // bool? get isInitialLoadComplete => null;
  bool _isInitialLoadComplete = false;
  bool get isInitialLoadComplete => _isInitialLoadComplete;

  Future<void> loadReminders() async {
    // FIX 4: 'state' is now correctly recognized as a property of StateNotifier
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
    );

    final savedReminder = await _dbService.create(newReminder);
    await _notificationService.scheduleDailyReminder(savedReminder);

    // state = [...state, savedReminder];
    // ✅ Reload from database to ensure data consistency
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

    state = state.where((item) => item.id != id).toList();
  }
}

// Global provider for accessing the state notifier
final remindersProvider =
    StateNotifierProvider<ReminderStateNotifier, List<MedicineReminder>>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return ReminderStateNotifier(service);
});
