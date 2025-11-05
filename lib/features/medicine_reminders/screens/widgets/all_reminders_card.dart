import 'package:elderly_prototype_app/features/medicine_reminders/data/models/medicine_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../services/reminder_state_notifier.dart';

class AllRemindersCard extends ConsumerWidget {
  final MedicineReminder reminder;
  const AllRemindersCard({super.key, required this.reminder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notifier = ref.read(remindersProvider.notifier);

    // Format the times to display
    final timeStrings = reminder.times.map((timeStr) {
      final parts = timeStr.split(':');
      final time =
          TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      // Format as 12-hour clock (e.g., "8:00 AM")
      return DateFormat.jm()
          .format(DateTime(2020, 1, 1, time.hour, time.minute));
    }).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    reminder.name,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary),
                  ),
                ),
                Switch(
                  value: reminder.isActive,
                  onChanged: (value) {
                    notifier.toggleReminder(reminder);
                  },
                  activeColor: theme.colorScheme.primary,
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey.withOpacity(0.3),
                ),
              ],
            ),
            Text(
              '${reminder.dosage} - ${timeStrings.length} time(s) daily',
              style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.secondary,
                  fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: timeStrings.map((time) {
                return Chip(
                  label: Text(time),
                  backgroundColor:
                      theme.colorScheme.secondary.withOpacity(0.15),
                  labelStyle: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Divider(color: theme.colorScheme.secondary.withOpacity(0.3)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  // Use a more readable date format
                  '${DateFormat('MMM d, yyyy').format(reminder.startDate)} - ${DateFormat('MMM d, yyyy').format(reminder.endDate)}',
                  style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w600),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    // Add a confirmation dialog
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Reminder'),
                        content: Text(
                            'Are you sure you want to delete ${reminder.name}? This will remove all associated alarms.'),
                        actions: [
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                          TextButton(
                            child: const Text('Delete',
                                style: TextStyle(color: Colors.red)),
                            onPressed: () {
                              notifier.deleteReminder(reminder);
                              Navigator.of(ctx).pop();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
