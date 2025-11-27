// lib/features/emergency/screens/emergency_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants.dart';
import '../data/models/contact_model.dart';
import '../providers/contact_provider.dart';

class EmergencySettingsScreen extends ConsumerWidget {
  const EmergencySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsState = ref.watch(contactNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.sosSettingsTitle),
        backgroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showContactDialog(context, ref, null),
        label: const Text(AppStrings.addContactTitle),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFF48352A), // Base Brown
      ),
      body: contactsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (contacts) {
          if (contacts.isEmpty) {
            return const Center(child: Text(AppStrings.noContacts));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: contacts.length,
            separatorBuilder: (ctx, i) => const Divider(),
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: contact.isPrimary
                      ? Colors.red.shade100
                      : Colors.grey.shade200,
                  child: Icon(
                    contact.isPrimary ? Icons.star : Icons.person,
                    color: contact.isPrimary ? Colors.red : Colors.grey,
                  ),
                ),
                title: Text(contact.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(contact.phoneNumber),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () =>
                          _showContactDialog(context, ref, contact),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => ref
                          .read(contactNotifierProvider.notifier)
                          .deleteContact(contact.id!),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Dialog for Adding OR Editing
  void _showContactDialog(
      BuildContext context, WidgetRef ref, EmergencyContact? contact) {
    final nameController = TextEditingController(text: contact?.name ?? '');
    final phoneController =
        TextEditingController(text: contact?.phoneNumber ?? '');
    bool isPrimary = contact?.isPrimary ?? false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(contact == null
                  ? AppStrings.addContactTitle
                  : AppStrings.editContactTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                          labelText: AppStrings.contactNameHint),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                          labelText: AppStrings.contactPhoneHint),
                    ),
                    const SizedBox(height: 15),
                    SwitchListTile(
                      title: const Text(AppStrings.isPrimaryLabel),
                      subtitle: const Text(AppStrings.isPrimaryHint,
                          style: TextStyle(fontSize: 11)),
                      value: isPrimary,
                      activeColor: Colors.red,
                      onChanged: (val) {
                        setState(() => isPrimary = val);
                      },
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Button color
                    foregroundColor: Colors.white, // Text color
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  onPressed: () {
                    if (nameController.text.isEmpty ||
                        phoneController.text.isEmpty) return;

                    if (contact == null) {
                      // ADD NEW
                      ref.read(contactNotifierProvider.notifier).addContact(
                            nameController.text,
                            phoneController.text,
                            isPrimary,
                          );
                    } else {
                      // UPDATE EXISTING
                      ref.read(contactNotifierProvider.notifier).updateContact(
                            contact.copyWith(
                              name: nameController.text,
                              phoneNumber: phoneController.text,
                              isPrimary: isPrimary,
                            ),
                          );
                    }
                    Navigator.pop(context);
                  },
                  child: const Text(
                    AppStrings.saveLabel,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }
}
