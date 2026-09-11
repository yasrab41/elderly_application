import 'package:elderly_prototype_app/features/medicine_reminders/data/datasources/database_service.dart';
import 'package:elderly_prototype_app/features/medicine_reminders/services/reminder_state_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elderly_prototype_app/core/localization/language_controller.dart';
import 'package:intl/intl.dart';
import 'package:elderly_prototype_app/core/constants.dart';
import '../../../authentication/services/auth_service.dart';

class TakenDosesNotifier extends StateNotifier<Set<String>> {
  final DatabaseService _dbService;
  final String _todayDateStr;
  final String _userId;

  TakenDosesNotifier(this._dbService, this._userId)
      : _todayDateStr = DateFormat('yyyy-MM-dd').format(DateTime.now()),
        super({}) {
    if (_userId.isNotEmpty) {
      _loadTakenDoses(); // Load from DB immediately
    }
  }

  Future<void> _loadTakenDoses() async {
    // Pass userId to DB call
    state = await _dbService.getTakenDosesForDate(_todayDateStr, _userId);
  }

  Future<void> markAsTaken(String uniqueDoseId) async {
    if (_userId.isEmpty) return;
    // Pass userId to DB call
    await _dbService.markDoseAsTaken(uniqueDoseId, _todayDateStr, _userId);
    state = {...state, uniqueDoseId};
  }
}

// 🛑 MODIFIED PROVIDER WITH FIX 🛑
final takenDosesProvider =
    StateNotifierProvider<TakenDosesNotifier, Set<String>>((ref) {
  // Watch auth state, which is User?
  final user = ref.watch(authNotifierProvider);

  // FIX: Use safe access on the nullable user object (user?)
  final userId = user?.uid ?? ''; // Get user ID

  // Pass user ID to the notifier
  return TakenDosesNotifier(DatabaseService.instance, userId);
});
// ------------------------------------

class TodaysScheduleCard extends ConsumerWidget {
  final MedicineDose dose;
  const TodaysScheduleCard({super.key, required this.dose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final reminder = dose.reminder;

    final doseTime = DateFormat.jm(AppLanguageController.intlLocale).format(
        DateTime(2020, 1, 1, dose.timeOfDay.hour, dose.timeOfDay.minute));

    final uniqueDoseId = '${reminder.id}-${dose.timeStr}';

    final isTaken = ref.watch(takenDosesProvider).contains(uniqueDoseId);

    // (Grace period logic remains the same)
    final now = TimeOfDay.now();
    final int nowInMinutes = now.hour * 60 + now.minute;
    final int doseTimeInMinutes =
        dose.timeOfDay.hour * 60 + dose.timeOfDay.minute;
    const int gracePeriodInMinutes = 5;
    final bool isMissed =
        !isTaken && (nowInMinutes > (doseTimeInMinutes + gracePeriodInMinutes));
    final bool isPending = !isTaken && !isMissed;

    // (Color logic remains the same)
    final Color cardColor;
    final Color iconBackgroundColor;
    final Color iconColor;
    final Color primaryTextColor;
    final Color secondaryTextColor;
    final TextDecoration? textDecoration;
    final IconData iconData;

    if (isTaken) {
      cardColor = Colors.green.shade50;
      iconBackgroundColor = Colors.green.shade100;
      iconColor = Colors.green.shade800;
      primaryTextColor = Colors.green.shade800;
      secondaryTextColor = Colors.green.shade700;
      textDecoration = TextDecoration.lineThrough;
      iconData = Icons.check_circle_outline;
    } else if (isMissed) {
      cardColor = Colors.red.shade50;
      iconBackgroundColor = Colors.red.shade100;
      iconColor = Colors.red.shade800;
      primaryTextColor = Colors.red.shade800;
      secondaryTextColor = Colors.red.shade700;
      textDecoration = null;
      iconData = Icons.warning_amber_rounded;
    } else {
      // isPending
      cardColor = Colors.brown.shade50;
      iconBackgroundColor = theme.colorScheme.primary.withOpacity(0.1);
      iconColor = theme.colorScheme.primary;
      primaryTextColor = theme.colorScheme.primary;
      secondaryTextColor = theme.colorScheme.secondary;
      textDecoration = null;
      iconData = Icons.medication_outlined;
    }

    // (UI build method remains the same)
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: iconColor, size: 24),
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
                      color: primaryTextColor,
                      decoration: textDecoration,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${AppStrings.doseTimePrefix}$doseTime - ${reminder.dosage}',
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryTextColor,
                      decoration: textDecoration,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (isTaken)
              Text(
                AppStrings.takenLabel,
                style: TextStyle(
                  color: primaryTextColor,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              ElevatedButton(
                onPressed: () {
                  // 7. Call the notifier to mark as taken
                  ref
                      .read(takenDosesProvider.notifier)
                      .markAsTaken(uniqueDoseId);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text(AppStrings.markedAsTakenMessage(reminder.name)),
                      backgroundColor: theme.colorScheme.primary,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isMissed
                      ? Colors.red.shade700
                      : theme.colorScheme.secondary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: Text(isMissed
                    ? AppStrings.takeLateButton
                    : AppStrings.takeNowButton),
              ),
          ],
        ),
      ),
    );
  }
}
