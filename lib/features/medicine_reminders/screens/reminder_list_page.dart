import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/reminder_state_notifier.dart';
import 'add_reminder_page.dart';
import 'widgets/todays_schedule_card.dart'; // New Widget
import 'widgets/all_reminders_card.dart'; // New Widget

class ReminderListPage extends ConsumerWidget {
  const ReminderListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(remindersProvider.notifier);
    final allReminders = ref.watch(remindersProvider);
    final todaysReminders = notifier.todaysReminders; // Use the new getter
    final isLoaded = notifier.isInitialLoadComplete;

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light background
      appBar: AppBar(
        title: const Text('Medicine Reminders'),
        backgroundColor: theme.colorScheme.primary, // Modern UI
        elevation: 0,
        foregroundColor: theme.colorScheme.primary, // Brown text/icons
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle,
                color: theme.colorScheme.secondary, size: 30),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const AddReminderPage(),
              ));
            },
          ),
        ],
      ),
      body: !isLoaded
          ? Center(
              child:
                  CircularProgressIndicator(color: theme.colorScheme.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // --- TODAY'S SCHEDULE SECTION ---
                  Text(
                    "Today's Schedule",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (todaysReminders.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(
                        child: Text(
                          'No reminders scheduled for today.',
                          style: TextStyle(
                              fontSize: 15, color: theme.colorScheme.secondary),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: todaysReminders.length,
                      itemBuilder: (context, index) {
                        return TodaysScheduleCard(
                          reminder: todaysReminders[index],
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
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (allReminders.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(
                        child: Text(
                          'No reminders set yet. Tap + to add one.',
                          style: TextStyle(
                              fontSize: 15, color: theme.colorScheme.secondary),
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
            ),
    );
  }
}
