import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Using older StateNotifierProvider
import 'package:intl/intl.dart';
import '../../services/reminder_state_notifier.dart'; // For MedicineDose
import '../../data/datasources/database_service.dart';

// --- TakenDosesNotifier: Extends StateNotifier ---
class TakenDosesNotifier extends StateNotifier<Set<String>> {
  final DatabaseService _dbService;
  final String _todayDateStr;

  // Constructor now initializes dependencies and calls super({})
  TakenDosesNotifier(this._dbService)
      // Get today's date in YYYY-MM-DD format
      : _todayDateStr = DateFormat('yyyy-MM-dd').format(DateTime.now()),
        super({}) {
    // Start with an empty set
    _loadTakenDoses(); // Load from DB immediately
  }

  // Load persistent state from database
  Future<void> _loadTakenDoses() async {
    state = await _dbService.getTakenDosesForDate(_todayDateStr);
  }

  // Mark as taken and save to database
  Future<void> markAsTaken(String uniqueDoseId) async {
    // 1. Save to DB
    await _dbService.markDoseAsTaken(uniqueDoseId, _todayDateStr);
    // 2. Update in-memory state (this triggers the UI rebuild)
    state = {...state, uniqueDoseId};
  }
}

// Uses StateNotifierProvider
final takenDosesProvider =
    StateNotifierProvider<TakenDosesNotifier, Set<String>>((ref) {
  return TakenDosesNotifier(DatabaseService.instance);
});
// ------------------------------------

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

    // --- "TAKE NOW" LOGIC (Now Persistent) ---
    final uniqueDoseId = '${reminder.id}-${dose.timeStr}';

    final isTaken = ref.watch(takenDosesProvider).contains(uniqueDoseId);

    // --- 🛑 GRACE PERIOD LOGIC ---

    // 1. Get current time in minutes since midnight
    final now = TimeOfDay.now();
    final int nowInMinutes =
        now.hour * 60 + now.minute; // e.g., 10:00 AM -> 600

    // 2. Get dose time in minutes since midnight
    final doseTimeOfDay = dose.timeOfDay;
    final int doseTimeInMinutes =
        doseTimeOfDay.hour * 60 + doseTimeOfDay.minute; // e.g., 9:50 AM -> 590

    // 3. Define the grace period
    const int gracePeriodInMinutes = 5;

    // 4. Define 'isMissed'
    // It's missed if it's NOT taken AND the grace period is over.
    final bool isMissed =
        !isTaken && (nowInMinutes > (doseTimeInMinutes + gracePeriodInMinutes));

    // 5. Define 'isPending'
    // It's pending if it's NOT taken and NOT missed.
    // This means the time is either before, at, or within the grace period.
    final bool isPending = !isTaken && !isMissed;

    // 6. Define 'isGreyedOut' (for UI styling)
    // The card is greyed out if it's either Taken or Missed.
    final bool isGreyedOut = isTaken || isMissed;

    // --- 🛑 END GRACE PERIOD LOGIC ---

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: isGreyedOut ? Colors.grey[200] : Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Row(
          children: [
            // (Icon logic remains the same)
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
            // (Text logic remains the same)
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
                      decoration:
                          isGreyedOut ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
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

            // --- 🛑 UPDATED "TAKE NOW" BUTTON LOGIC ---
            if (isTaken)
              Text(
                'Taken ✔',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              )
            else if (isMissed) // Use the new 'isMissed' flag
              Text(
                'Missed',
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              )
            else // This is the 'isPending' state
              ElevatedButton(
                onPressed: () {
                  // Call the Notifier's method
                  ref
                      .read(takenDosesProvider.notifier)
                      .markAsTaken(uniqueDoseId);

                  // (Snackbar logic remains the same)
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
