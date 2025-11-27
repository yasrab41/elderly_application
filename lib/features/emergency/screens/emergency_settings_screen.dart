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
      backgroundColor: const Color(0xFFF5F5F5), // Light background
      appBar: AppBar(
        title: const Text(
          AppStrings.sosSettingsTitle,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF48352A), // Base Brown
        iconTheme: const IconThemeData(color: Colors.white), // White back arrow
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showContactDialog(context, ref, null),
        label: const Text('Add Contact', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.person_add, color: Colors.white),
        backgroundColor: const Color(0xFF48352A), // Base Brown
      ),
      body: contactsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (contacts) {
          if (contacts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.contact_emergency,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    AppStrings.noContacts,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: contacts.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: contact.isPrimary
                        ? Colors.red.shade100
                        : const Color(0xFFF0EBE8), // Light brown tint
                    child: Icon(
                      contact.isPrimary ? Icons.star : Icons.person,
                      color: contact.isPrimary
                          ? Colors.red
                          : const Color(0xFF48352A),
                    ),
                  ),
                  title: Text(
                    contact.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    contact.phoneNumber,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon:
                            const Icon(Icons.edit_outlined, color: Colors.blue),
                        onPressed: () =>
                            _showContactDialog(context, ref, contact),
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _confirmDelete(context, ref, contact),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- Confirmation Dialog for Deletion ---
  void _confirmDelete(
      BuildContext context, WidgetRef ref, EmergencyContact contact) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Contact?'),
        content: Text('Are you sure you want to delete ${contact.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(contactNotifierProvider.notifier)
                  .deleteContact(contact.id!);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --- Dialog for Adding OR Editing ---
  void _showContactDialog(
      BuildContext context, WidgetRef ref, EmergencyContact? contact) {
    // 1. Create a GlobalKey to manage the Form State
    final formKey = GlobalKey<FormState>();

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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text(
                contact == null
                    ? AppStrings.addContactTitle
                    : AppStrings.editContactTitle,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey, // Bind the key to the form
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- Name Field with Validation ---
                      TextFormField(
                        controller: nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: AppStrings.contactNameHint,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Contact name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // --- Phone Field with Numeric Validation ---
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: AppStrings.contactPhoneHint,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          prefixIcon: const Icon(Icons.phone_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Phone number is required';
                          }
                          // Regex: Allow digits and optional leading +
                          final phoneRegExp = RegExp(r'^[+0-9]+$');
                          if (!phoneRegExp.hasMatch(value.trim())) {
                            return 'Enter a valid number (digits only)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // --- Primary Contact Switch ---
                      Container(
                        decoration: BoxDecoration(
                          color: isPrimary
                              ? Colors.red.shade50
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isPrimary
                                ? Colors.red.shade200
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: SwitchListTile(
                          title: const Text(AppStrings.isPrimaryLabel,
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: const Text(AppStrings.isPrimaryHint,
                              style: TextStyle(fontSize: 12)),
                          value: isPrimary,
                          activeColor: Colors.red,
                          onChanged: (val) {
                            setState(() => isPrimary = val);
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF48352A), // Base Brown
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  onPressed: () {
                    // 2. Validate the Form
                    if (!formKey.currentState!.validate()) {
                      return; // Stop if invalid
                    }

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
                  child: const Text(AppStrings.saveLabel),
                )
              ],
            );
          },
        );
      },
    );
  }
}
