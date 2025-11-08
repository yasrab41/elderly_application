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
    final int nowInMinutes = now.hour * 60 + now.minute;

    // 2. Get dose time in minutes since midnight
    final doseTimeOfDay = dose.timeOfDay;
    final int doseTimeInMinutes =
        doseTimeOfDay.hour * 60 + doseTimeOfDay.minute;

    // 3. Define the grace period
    const int gracePeriodInMinutes = 5;

    // 4. Define 'isMissed' (the state where time has passed, but it hasn't been taken)
    final bool isMissed =
        !isTaken && (nowInMinutes > (doseTimeInMinutes + gracePeriodInMinutes));

    // 5. Define 'isPending'
    // It's pending if it's NOT taken and NOT missed
    final bool isPending = !isTaken && !isMissed;

    // --- 🛑 END GRACE PERIOD LOGIC ---

    // --- 🎨 NEW: Define State-Specific Colors ---
    final Color cardColor;
    final Color iconBackgroundColor;
    final Color iconColor;
    final Color primaryTextColor;
    final Color secondaryTextColor;
    final TextDecoration? textDecoration;
    final IconData iconData;

    if (isTaken) {
      cardColor = Colors.green.shade50; // Light green background
      iconBackgroundColor = Colors.green.shade100;
      iconColor = Colors.green.shade800;
      primaryTextColor = Colors.green.shade800;
      secondaryTextColor = Colors.green.shade700;
      textDecoration = TextDecoration.lineThrough;
      iconData = Icons.check_circle_outline; // Changed icon
    } else if (isMissed) {
      cardColor = Colors.red.shade50; // Light red background
      iconBackgroundColor = Colors.red.shade100;
      iconColor = Colors.red.shade800;
      primaryTextColor = Colors.red.shade800;
      secondaryTextColor = Colors.red.shade700;
      textDecoration = null; // No line-through, still actionable
      iconData = Icons.warning_amber_rounded; // Changed icon
    } else {
      // isPending
      cardColor = Colors.brown.shade50; // Default white
      iconBackgroundColor = theme.colorScheme.primary.withOpacity(0.1);
      iconColor = theme.colorScheme.primary;
      primaryTextColor = theme.colorScheme.primary;
      secondaryTextColor = theme.colorScheme.secondary;
      textDecoration = null;
      iconData = Icons.medication_outlined;
    }
    // --- 🎨 End Color Definitions ---

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: cardColor, // 🎨 Use new dynamic card color
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Row(
          children: [
            // (Icon logic remains the same)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color:
                    iconBackgroundColor, // 🎨 Use new dynamic icon background
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, // 🎨 Use new dynamic icon
                  color: iconColor, // 🎨 Use new dynamic icon color
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
                      color: primaryTextColor, // 🎨 Use new dynamic text color
                      decoration:
                          textDecoration, // 🎨 Use new dynamic decoration
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Time: $doseTime - ${reminder.dosage}',
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          secondaryTextColor, // 🎨 Use new dynamic text color
                      decoration: textDecoration,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // --- 🛑 UPDATED BUTTON/TEXT LOGIC ---
            if (isTaken)
              Text(
                'Taken ✔',
                style: TextStyle(
                  color: primaryTextColor, // 🎨 Use new (green) text color
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              // This is the combined PENDING and MISSED state, both show a button
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(takenDosesProvider.notifier)
                      .markAsTaken(uniqueDoseId);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Marked ${reminder.name} as taken!'),
                      backgroundColor: theme.colorScheme.primary,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  // 🚨 KEY CHANGE: Use Red color if missed, Secondary (Brown) if pending
                  backgroundColor: isMissed
                      ? Colors.red.shade600 // Red button on light red card
                      : theme.colorScheme.secondary, // Brown for pending
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: Text(isMissed ? 'Take (Late)' : 'Take Now'),
              ),
            // ---------------------------------
          ],
        ),
      ),
    );
  }
}
