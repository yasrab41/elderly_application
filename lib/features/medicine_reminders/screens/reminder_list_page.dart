import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_theme.dart'; // Import for theme colors
import '../services/reminder_state_notifier.dart'; // Notifier from services/
import 'widgets/reminder_card.dart'; // Card from screens/widgets

import 'add_reminder_page.dart'; // Sibling screen

class ReminderListPage extends ConsumerWidget {
  const ReminderListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // WATCH: Listen to the list state for automatic UI updates
    final reminders = ref.watch(remindersProvider);
    // READ: Get the Notifier instance to call methods
    final notifier = ref.read(remindersProvider.notifier);

    // Check the non-nullable loading flag from the Notifier
    final isLoaded = notifier.isInitialLoadComplete;

    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    Widget bodyContent;

    // --- State Handling ---
    if (!isLoaded) {
      // State 1: Show loading indicator while the initial database load runs
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (reminders.isEmpty) {
      // State 2: Show empty message after loading is complete
      bodyContent = Center(
        child: Text(
          'No reminders set. Tap + to add one!',
          style: TextStyle(color: secondaryColor, fontSize: 16),
        ),
      );
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
