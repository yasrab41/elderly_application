// lib/features/emergency/providers/contact_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../authentication/services/auth_service.dart'; // Ensure correct import
import '../data/datasources/emergency_db_service.dart';
import '../data/models/contact_model.dart';

// Service Provider
final emergencyDbServiceProvider = Provider((ref) => EmergencyDbService());

// StateNotifier
class ContactNotifier
    extends StateNotifier<AsyncValue<List<EmergencyContact>>> {
  final EmergencyDbService _dbService;
  final String _userId;

  ContactNotifier(this._dbService, this._userId)
      : super(const AsyncValue.loading()) {
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final contacts = await _dbService.getContacts(_userId);
      state = AsyncValue.data(contacts);
    } catch (e, stack) {
      state = AsyncValue.error(e, stackTrace: stack);
    }
  }

  Future<void> addContact(String name, String phone, bool isPrimary) async {
    try {
      final newContact = EmergencyContact(
        userId: _userId,
        name: name,
        phoneNumber: phone,
        isPrimary: isPrimary,
      );
      await _dbService.insertContact(newContact);
      await _loadContacts(); // Refresh list
    } catch (e) {
      // Handle error gracefully
    }
  }

  Future<void> updateContact(EmergencyContact contact) async {
    try {
      await _dbService.updateContact(contact);
      await _loadContacts();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteContact(int id) async {
    try {
      await _dbService.deleteContact(id, _userId);
      await _loadContacts();
    } catch (e) {
      // Handle error
    }
  }
}

// The Main Provider used by UI
final contactNotifierProvider =
    StateNotifierProvider<ContactNotifier, AsyncValue<List<EmergencyContact>>>(
        (ref) {
  // 1. Listen to Auth changes to get User ID
  final user = ref.watch(authNotifierProvider);
  final dbService = ref.watch(emergencyDbServiceProvider);

  // 2. If no user, return empty state
  if (user == null) {
    return ContactNotifier(dbService, '')..state = const AsyncValue.data([]);
  }

  // 3. Return notifier with actual User ID
  return ContactNotifier(dbService, user.uid);
});
