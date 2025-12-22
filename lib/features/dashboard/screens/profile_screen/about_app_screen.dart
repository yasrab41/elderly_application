import 'package:flutter/material.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About App')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Logo / Header
            Icon(Icons.health_and_safety,
                size: 80, color: Theme.of(context).primaryColor),
            const SizedBox(height: 16),
            const Text('Elderly Care Assistant',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text('Version 1.0.0', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),

            // Features
            const Align(
                alignment: Alignment.centerLeft,
                child: Text('Core Features:',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 10),
            _featureItem('Medicine Reminder'),
            _featureItem('Emergency SOS'),
            _featureItem('Fitness Tracking'),
            _featureItem('Health Monitoring'),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),

            // Creator Info
            const Text('Created By', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 5),
            const Text('Yasrab Memon',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.email, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Text('yasrab41memon@gmail.com',
                    style: TextStyle(color: Colors.blue[700])),
              ],
            ),

            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(8)),
              child: const Text(
                'This app is designed with accessibility in mind to assist elderly users in their daily lives.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
