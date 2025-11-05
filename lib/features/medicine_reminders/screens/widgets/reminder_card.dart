import 'package:elderly_prototype_app/features/medicine_reminders/data/models/medicine_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Custom Widget for displaying each Reminder Item
class ReminderCard extends StatelessWidget {
  final MedicineReminder reminder;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final Color primaryColor;
  final Color secondaryColor;

  const ReminderCard({
    required this.reminder,
    required this.onToggle,
    required this.onDelete,
    required this.primaryColor,
    required this.secondaryColor,
    super.key,
  });

  // ... (rest of the widget code remains the same) ...
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: Icon(
          Icons.access_time,
          color: reminder.isActive ? primaryColor : Colors.grey,
        ),
        title: Text(
          reminder.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: reminder.isActive ? primaryColor : Colors.grey,
            decoration: reminder.isActive
                ? TextDecoration.none
                : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${reminder.dosage} | ${reminder.times.join(", ")}',
              style: TextStyle(
                color: reminder.isActive ? secondaryColor : Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: reminder.isActive,
              onChanged: (_) => onToggle(),
              activeThumbColor: primaryColor,
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red.shade400),
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: Text('Are you sure you want to delete ${reminder.name}?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: TextStyle(color: secondaryColor)),
          ),
          TextButton(
            onPressed: () {
              onDelete();
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
