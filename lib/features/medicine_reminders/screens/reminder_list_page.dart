import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Import for date formatting

// Theme from config/
import '../services/reminder_state_notifier.dart'; // Notifier from services/
import 'widgets/all_reminders_card.dart';
import 'widgets/todays_schedule_card.dart'; // Import the card
import 'add_reminder_page.dart'; // Sibling screen

class ReminderListPage extends ConsumerWidget {
  const ReminderListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider to listen for changes
    final allReminders = ref.watch(remindersProvider);
    final notifier = ref.read(remindersProvider.notifier);

    // 🔑 CRITICAL FIX: Ensure the getter name is todaysDoses, not todaysReminders
    final todaysDoses = notifier.todaysDoses;

    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    // Debugging helper
    final todayFormatted = DateFormat.yMMMEd().format(DateTime.now());

    // --- State Handling ---
    Widget bodyContent;

    // Check the non-nullable boolean getter from the notifier.
    if (!notifier.isInitialLoadComplete) {
      // State 1: Show loading indicator while the initial database load runs
      bodyContent =
          Center(child: CircularProgressIndicator(color: primaryColor));
    } else {
      // State 2: Show the main content
      bodyContent = SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // UI TWEAK: Display the current date for verification
            Text(
              "Today's Date: $todayFormatted",
              style: TextStyle(
                fontSize: 14,
                color: secondaryColor,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 10),

            // --- TODAY'S SCHEDULE SECTION ---
            Text(
              "Today's Schedule",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),

            if (todaysDoses.isEmpty) // Check the new dose list
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: Text(
                    'No reminders scheduled for today.',
                    style: TextStyle(fontSize: 15, color: secondaryColor),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: todaysDoses.length, // Use the dose list length
                itemBuilder: (context, index) {
                  // Pass the individual dose to the card
                  return TodaysScheduleCard(
                    dose: todaysDoses[index],
                  );
                },
              ),

            const SizedBox(height: 30),

            // --- ALL REMINDERS SECTION ---
            Text(
              'All Reminders',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            if (allReminders.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: Text(
                    'No reminders set yet. Tap + to add one.',
                    style: TextStyle(fontSize: 15, color: secondaryColor),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: allReminders.length,
                itemBuilder: (context, index) {
                  return AllRemindersCard(
                    reminder: allReminders[index],
                  );
                },
              ),
            const SizedBox(height: 20), // Padding at the bottom
          ],
        ),
      );
    }
    // -----------------------

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Medicine Reminders'),
        backgroundColor: primaryColor, // Modern UI
        elevation: 0,
        foregroundColor: secondaryColor, // Brown text/icons
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle, color: Colors.white, size: 30),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const AddReminderPage(),
              ));
            },
          ),
        ],
      ),
      body: bodyContent, // Use the determined content widget
    );
  }
}
