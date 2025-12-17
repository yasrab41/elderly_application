import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Temporary state for UI demonstration
  bool _medicine = true;
  bool _exercise = false;
  bool _health = true;
  bool _emergency = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Manage Alerts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          const Text('Choose which reminders you want to receive.',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          _buildSwitch('Medicine Reminders', 'Get alerts for your pills',
              _medicine, (v) => setState(() => _medicine = v)),
          _buildSwitch('Exercise Reminders', 'Daily walking alerts', _exercise,
              (v) => setState(() => _exercise = v)),
          _buildSwitch('Health Checks', 'BP & Weight reminders', _health,
              (v) => setState(() => _health = v)),
          Divider(height: 30, color: Colors.grey[300]),
          _buildSwitch('Emergency Alerts', 'SOS notifications', _emergency,
              (v) => setState(() => _emergency = v),
              isCritical: true),
        ],
      ),
    );
  }

  Widget _buildSwitch(
      String title, String subtitle, bool value, Function(bool) onChanged,
      {bool isCritical = false}) {
    return SwitchListTile(
      activeColor: isCritical ? Colors.red : Theme.of(context).primaryColor,
      title: Text(title,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isCritical ? Colors.red : Colors.black)),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
}
