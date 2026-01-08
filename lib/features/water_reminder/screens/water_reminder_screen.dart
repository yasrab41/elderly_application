import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:intl/intl.dart';

import '../../../core/constants.dart';
import '../data/models/water_models.dart';
import 'reminder_settings_modal.dart';
import '../services/notification_service.dart';
import '../services/water_notifier.dart';

class WaterReminderScreen extends ConsumerWidget {
  const WaterReminderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waterState = ref.watch(waterProvider);
    final notifier = ref.read(waterProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.waterTitle),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: waterState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildProgressCard(waterState, context),
                  const SizedBox(height: 20),
                  _buildSettingsCard(context, waterState, notifier),
                  const SizedBox(height: 20),
                  _buildAddWaterSection(notifier),
                  const SizedBox(height: 20),
                  _buildHistoryList(waterState, notifier),
                ],
              ),
            ),
    );
  }

  Widget _buildProgressCard(WaterState state, BuildContext context) {
    bool goalReached = state.currentIntake >= state.settings.dailyGoal;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          Image.asset('assets/images/water_bottle.png',
              height: 50,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.local_drink, size: 40, color: Colors.blue)),
          const SizedBox(height: 10),
          Text(
            "${state.currentIntake}ml",
            style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700),
          ),
          Text(
            "${AppStrings.goalLabel} ${state.settings.dailyGoal}ml",
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          LinearPercentIndicator(
            lineHeight: 20.0,
            percent: state.progress,
            barRadius: const Radius.circular(10),
            backgroundColor: Colors.grey.shade200,
            progressColor: goalReached ? Colors.green : Colors.blue,
            animation: true,
          ),
        ],
      ),
    );
  }

  // --- NEW: Helper to calculate countdown string ---
  String _getNextReminderString(WaterSettings settings) {
    if (!settings.isEnabled) return "Reminders disabled";

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, settings.startTOD.hour,
        settings.startTOD.minute);
    final end = DateTime(now.year, now.month, now.day, settings.endTOD.hour,
        settings.endTOD.minute);

    DateTime currentSlot = start;

    // Find next slot
    while (currentSlot.isBefore(end)) {
      if (currentSlot.isAfter(now)) {
        final diff = currentSlot.difference(now);
        if (diff.inHours > 0) {
          return "Next: in ${diff.inHours}h ${diff.inMinutes % 60}m";
        } else {
          return "Next: in ${diff.inMinutes} min";
        }
      }
      currentSlot =
          currentSlot.add(Duration(minutes: settings.intervalMinutes));
    }

    return "Done for today";
  }

  Widget _buildSettingsCard(
      BuildContext context, WaterState state, WaterNotifier notifier) {
    // Calculate display text for interval
    String intervalText;
    if (state.settings.intervalMinutes < 60) {
      intervalText = "${state.settings.intervalMinutes} min";
    } else {
      double hours = state.settings.intervalMinutes / 60;
      intervalText = "${hours.toStringAsFixed(hours % 1 == 0 ? 0 : 1)} hour(s)";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(AppStrings.remindersTitle,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  // Display Interval
                  Text(
                    state.settings.isEnabled
                        ? "Every $intervalText (${state.settings.soundType.toUpperCase()})"
                        : AppStrings.disabled,
                    style: const TextStyle(color: Colors.black87),
                  ),
                  // NEW: Display Countdown
                  if (state.settings.isEnabled)
                    Text(
                      _getNextReminderString(state.settings),
                      style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                ],
              ),
              Switch(
                value: state.settings.isEnabled,
                activeColor: Colors.blue,
                onChanged: (val) {
                  notifier
                      .updateSettings(state.settings.copyWith(isEnabled: val));
                },
              )
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.settings),
              label: const Text(AppStrings.changeSettings),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade50,
                foregroundColor: Colors.blue,
                elevation: 0,
              ),
              onPressed: () => _openAdvancedSettings(context, state, notifier),
            ),
          )
        ],
      ),
    );
  }

  void _openAdvancedSettings(
      BuildContext context, WaterState state, WaterNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReminderSettingsModal(
        // FIX: Pass minutes directly
        currentInterval: state.settings.intervalMinutes.toDouble(),
        currentSound: state.settings.soundType,
        currentVibration: state.settings.isVibration,
        currentActiveStart: state.settings.startTime,
        currentActiveEnd: state.settings.endTime,

        onSave: ({
          required String startMode,
          required String customStartTime,
          required double intervalMinutes,
          required String activeStart,
          required String activeEnd,
          required String sound,
          required bool vibration,
        }) {
          // Pass data to notifier without rounding to hours
          notifier.updateWaterSettings(
              startMode: startMode,
              customStartTime: customStartTime,
              intervalMinutes: intervalMinutes,
              activeStart: activeStart,
              activeEnd: activeEnd,
              sound: sound,
              vibration: vibration);
        },
      ),
    );
  }

  Widget _buildAddWaterSection(WaterNotifier notifier) {
    final amounts = [200, 250, 300, 500];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(AppStrings.addWaterTitle,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: amounts.length,
            itemBuilder: (context, index) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => notifier.addWater(amounts[index]),
                child: Text("${amounts[index]}ml",
                    style: const TextStyle(fontSize: 18, color: Colors.white)),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(WaterState state, WaterNotifier notifier) {
    if (state.todayLogs.isEmpty) {
      return Column(
        children: [
          Icon(Icons.water_drop_outlined,
              size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          Text(AppStrings.noWaterLogged,
              style: TextStyle(color: Colors.grey.shade400)),
          const SizedBox(height: 40),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(AppStrings.todaysWater,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.todayLogs.length,
          itemBuilder: (context, index) {
            final log = state.todayLogs[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.water_drop, color: Colors.blue),
                ),
                title: Text("${log.amount}ml",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(DateFormat('h:mm a').format(log.timestamp)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => notifier.deleteLog(log.id!),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
