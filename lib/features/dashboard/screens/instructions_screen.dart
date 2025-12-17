import 'package:flutter/material.dart';

class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('How to Use')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildStep(Icons.medication, 'Medicine Reminders',
              'The app will remind you when to take your pills. Just tap "Taken" when you are done.'),
          _buildStep(Icons.sos, 'Emergency SOS',
              'In case of emergency, press the big Red Button to alert your family immediately.'),
          _buildStep(Icons.directions_walk, 'Fitness',
              'We track your daily steps to help you stay active and healthy.'),
          _buildStep(Icons.favorite, 'Health Tracking',
              'You can log your blood pressure and weight to keep a history for your doctor.'),
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
