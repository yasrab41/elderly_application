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
    // Optimization: If no user ID is present (e.g. logged out),
    // set empty data synchronously and return.
    // This avoids async gaps and database calls for unauthenticated states.
    if (_userId.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    // Check if disposed before starting work
    if (!mounted) return;

    try {
      final contacts = await _dbService.getContacts(_userId);

      // Check mounted again before updating state after async await
      if (mounted) {
        state = AsyncValue.data(contacts);
      }
    } catch (e, stack) {
      if (mounted) {
        state = AsyncValue.error(e, stackTrace: stack);
      }
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

      if (mounted) {
        await _loadContacts();
      }
    } catch (e) {
      // Handle error gracefully
    }
  }

  Future<void> updateContact(EmergencyContact contact) async {
    try {
      await _dbService.updateContact(contact);

      if (mounted) {
        await _loadContacts();
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteContact(int id) async {
    try {
      await _dbService.deleteContact(id, _userId);

      if (mounted) {
        await _loadContacts();
      }
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

  // 2. Pass the UID (or empty string if null) to the notifier.
  // We let the Notifier handle the empty string logic internally (see _loadContacts).
  final userId = user?.uid ?? '';

  return ContactNotifier(dbService, userId);
});
