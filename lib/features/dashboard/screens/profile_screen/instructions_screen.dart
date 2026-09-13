import 'package:flutter/material.dart';
import 'package:elderly_prototype_app/core/constants.dart';

class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.instructionsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildStep(Icons.medication, AppStrings.medicineRemindersTitle,
              AppStrings.stepMedicineRemindersDesc),
          _buildStep(Icons.sos, AppStrings.featureEmergencySOS,
              AppStrings.stepEmergencyDesc),
          _buildStep(Icons.directions_walk, AppStrings.stepFitnessTitle,
              AppStrings.stepFitnessDesc),
          _buildStep(Icons.favorite, AppStrings.featureHealthTracking,
              AppStrings.stepHealthTrackingDesc),
          _buildStep(Icons.water_drop, AppStrings.waterTitle,
              AppStrings.stepWaterReminderDesc),
          _buildStep(Icons.near_me, AppStrings.nearbyServicesTitle,
              AppStrings.stepNearbyServicesDesc),
          _buildStep(Icons.people_alt, AppStrings.friendNetworkTitle,
              AppStrings.stepFriendNetworkDesc),
          _buildStep(Icons.smart_toy, AppStrings.chatbotTitle,
              AppStrings.stepAIAssistantDesc),
          _buildStep(Icons.psychology, AppStrings.brainGamesTitle,
              AppStrings.stepBrainGamesDesc),
        ],
      ),
    );
  }

  Widget _buildStep(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 40, color: Colors.blueGrey),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(description,
                    style: const TextStyle(fontSize: 16, height: 1.4)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
