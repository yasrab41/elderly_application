import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../services/reminder_state_notifier.dart';
import 'widgets/all_reminders_card.dart';
import 'widgets/todays_schedule_card.dart';
import 'add_reminder_page.dart';

class ReminderListPage extends ConsumerWidget {
  const ReminderListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allReminders = ref.watch(remindersProvider);
    final notifier = ref.read(remindersProvider.notifier);
    final todaysDoses = notifier.todaysDoses;

    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    // Helper method to navigate to Add Page
    void goToAddPage() {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const AddReminderPage(),
      ));
    }

    final todayFormatted = DateFormat.yMMMEd().format(DateTime.now());

    // --- Content Widget Construction ---
    Widget contentList;

    if (!notifier.isInitialLoadComplete) {
      contentList =
          Center(child: CircularProgressIndicator(color: primaryColor));
    } else {
      contentList = SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              "Today's Date: $todayFormatted",
              style: TextStyle(
                fontSize: 14,
                color: secondaryColor,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 10),

            // --- TODAY'S SCHEDULE ---
            Text(
              "Today's Schedule",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),

            if (todaysDoses.isEmpty)
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
                itemCount: todaysDoses.length,
                itemBuilder: (context, index) {
                  return TodaysScheduleCard(
                    dose: todaysDoses[index],
                  );
                },
              ),

            const SizedBox(height: 30),

            // --- ALL REMINDERS ---
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
                    'No reminders set yet.',
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
            // Add extra padding at the bottom of the list so content isn't cramped
            const SizedBox(height: 20),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Medicine Reminders'),
        backgroundColor: primaryColor,
        elevation: 0,
        foregroundColor: Colors.white, // Improved contrast for AppBar text
        actions: [
          // Keeping this for "power users" / caregivers
          IconButton(
            icon: const Icon(Icons.add_circle, size: 30),
            onPressed: goToAddPage,
          ),
        ],
      ),
      // UX CHANGE: Used Column + Expanded so the button stays pinned at bottom
      body: Column(
        children: [
          // 1. The main scrollable content takes all available space
          Expanded(child: contentList),

          // 2. Fixed Bottom Action Area (Elderly Friendly)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: SafeArea(
              // Ensures it respects iPhone home indicator
              child: ElevatedButton.icon(
                onPressed: goToAddPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF48352A), // Base Brown / Primary
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                icon: const Icon(Icons.add_circle_outline, size: 28),
                label: const Text(
                  "Add Medicine",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
