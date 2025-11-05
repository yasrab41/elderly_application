import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_theme.dart'; // Theme from config/
import '../services/reminder_state_notifier.dart'; // Notifier from services/
import 'widgets/reminder_card.dart'; // Card from screens/widgets

import 'add_reminder_page.dart'; // Sibling screen

class ReminderListPage extends ConsumerWidget {
  const ReminderListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔑 FIX: Watch the provider to listen for changes
    final reminders = ref.watch(remindersProvider);
    final notifier = ref.read(remindersProvider.notifier);

    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    // --- State Handling ---
    Widget bodyContent;

    if (reminders.isEmpty && notifier.isInitialLoadComplete == true) {
      // State 1: Data is empty after loading is complete
      bodyContent = Center(
        child: Text(
          'No reminders set. Tap + to add one!',
          style: TextStyle(color: secondaryColor, fontSize: 16),
        ),
      );
    } else if (reminders.isEmpty && !(notifier.isInitialLoadComplete ?? true)) {
      // State 2: Data is currently loading (the list is empty, but load is running)
      // This assumes you add 'isInitialLoadComplete' to your ReminderStateNotifier
      bodyContent = const Center(child: CircularProgressIndicator());
    } else {
      // State 3: Data is available
      bodyContent = ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: reminders.length,
        itemBuilder: (context, index) {
          final reminder = reminders[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ReminderCard(
              reminder: reminder,
              onToggle: () => notifier.toggleReminder(reminder),
              onDelete: () => notifier.deleteReminder(reminder.id!),
              primaryColor: primaryColor,
              secondaryColor: secondaryColor,
            ),
          );
        },
      );
    }
    // -----------------------

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Reminders'),
      ),
      body: bodyContent, // Use the determined content widget
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const AddReminderPage(),
          ));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
