import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import '../../services/reminder_state_notifier.dart';

// This provider will store a Set of unique dose IDs that have been "taken".
// A unique ID is "reminderId-HH:mm", e.g., "7-19:41"
final takenDosesProvider = StateProvider<Set<String>>((ref) => {});

class TodaysScheduleCard extends ConsumerWidget {
  final MedicineDose dose;
  const TodaysScheduleCard({super.key, required this.dose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final reminder = dose.reminder; // Get the parent reminder from the dose

    // Format the specific time for this dose
    final doseTime = DateFormat.jm().format(
        DateTime(2020, 1, 1, dose.timeOfDay.hour, dose.timeOfDay.minute));

    // --- "TAKE NOW" LOGIC ---
    // Create a unique ID for this specific dose
    final uniqueDoseId = '${reminder.id}-${dose.timeStr}';

    // Watch the provider to see if this dose is in the "taken" set
    final isTaken = ref.watch(takenDosesProvider).contains(uniqueDoseId);

    // Check if the dose time has already passed
    final now = TimeOfDay.now();
    final doseTimeOfDay = dose.timeOfDay;
    // Check if current hour is greater OR (current hour is same AND current minute is greater)
    final bool hasPassed = (doseTimeOfDay.hour < now.hour) ||
        (doseTimeOfDay.hour == now.hour && doseTimeOfDay.minute < now.minute);
    // ----------------------------

    // Card is greyed out if taken OR if the time has passed and it wasn't taken
    final bool isGreyedOut = isTaken || hasPassed;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      // Change color if it's been taken or has passed
      color: isGreyedOut ? Colors.grey[200] : Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Row(
          children: [
            // Icon in a circle
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isGreyedOut
                    ? Colors.grey[400]
                    : theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(isTaken ? Icons.check : Icons.medication_outlined,
                  color: isGreyedOut ? Colors.white : theme.colorScheme.primary,
                  size: 24),
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
                      color: isGreyedOut
                          ? Colors.grey[600]
                          : theme.colorScheme.primary,
                      // Add strikethrough if taken or passed
                      decoration:
                          isGreyedOut ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    // Show the specific dose time
                    'Time: $doseTime - ${reminder.dosage}',
                    style: TextStyle(
                        fontSize: 14,
                        color: isGreyedOut
                            ? Colors.grey[600]
                            : theme.colorScheme.secondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // --- "TAKE NOW" BUTTON LOGIC ---
            if (isTaken)
              // If taken, show a simple "Taken" text
              Text(
                'Taken ✔',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              )
            else if (hasPassed)
              // If time passed and not taken, show "Missed"
              Text(
                'Missed',
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              // If not taken and not passed, show the button
              ElevatedButton(
                onPressed: () {
                  // 1. Update the StateProvider to mark this dose as taken
                  ref.read(takenDosesProvider.notifier).update((state) {
                    // Return a new Set with the uniqueDoseId added
                    return {...state, uniqueDoseId};
                  });

                  // 2. Show a snackbar
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
            // ---------------------------------
          ],
        ),
      ),
    );
  }
}
