import 'package:elderly_prototype_app/features/medicine_reminders/data/models/medicine_model.dart';
import 'package:elderly_prototype_app/features/medicine_reminders/services/reminder_state_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class TodaysScheduleCard extends ConsumerWidget {
  final MedicineReminder reminder;
  const TodaysScheduleCard({super.key, required this.reminder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Find the next time for today
    final now = TimeOfDay.now();
    String nextTime = "Completed";
    String rawNextTime = "";

    // Find the first time today that hasn't passed yet
    for (final timeStr in reminder.times) {
      final timeParts = timeStr.split(':');
      final time = TimeOfDay(
          hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
      if (time.hour > now.hour ||
          (time.hour == now.hour && time.minute >= now.minute)) {
        nextTime = DateFormat.jm()
            .format(DateTime(2020, 1, 1, time.hour, time.minute));
        rawNextTime = timeStr; // e.g., "08:00"
        break;
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Row(
          children: [
            // Icon in a circle
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.medication_outlined,
                  color: theme.colorScheme.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.name,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Next: $nextTime - ${reminder.dosage}',
                    style: TextStyle(
                        fontSize: 14, color: theme.colorScheme.secondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (nextTime != "Completed")
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(remindersProvider.notifier)
                      .markAsTaken(reminder, rawNextTime);
                  // Show a snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Marked ${reminder.name} as taken!'),
                      backgroundColor: theme.colorScheme.primary,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text('Take Now'),
              ),
          ],
        ),
      ),
    );
  }
}
