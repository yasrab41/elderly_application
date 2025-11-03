import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Import path correct for your 'services' folder
import '../services/reminder_state_notifier.dart';

class AddReminderPage extends ConsumerStatefulWidget {
  const AddReminderPage({super.key});

  @override
  ConsumerState<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends ConsumerState<AddReminderPage> {
  // 1. The GlobalKey is REQUIRED to interact with the Form
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _dosage = '';
  TimeOfDay _time = TimeOfDay.now(); // Initial time

  void _selectTime() async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (newTime != null) {
      setState(() {
        _time = newTime;
      });
    }
  }

  void _submit() async {
    // 2. CHECK: If the current state is NOT valid (e.g., fields are empty),
    // this function returns immediately and nothing is saved.
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Call the StateNotifier to save data and schedule notification
      await ref.read(remindersProvider.notifier).addReminder(
            name: _name,
            dosage: _dosage,
            time: _time,
          );

      // 3. Close the page after a successful save
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminder saved successfully!')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Reminder'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // 4. This key links the form to the validation logic
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Medicine Name
              TextFormField(
                decoration: const InputDecoration(labelText: 'Medicine Name'),
                // 5. VALIDATOR: Must return an error message (String) if invalid
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Please enter a name.'
                    : null,
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 20),

              // Dosage
              TextFormField(
                decoration: const InputDecoration(labelText: 'Dosage'),
                // 5. VALIDATOR: Must return an error message (String) if invalid
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Please enter a dosage.'
                    : null,
                onSaved: (value) => _dosage = value!,
              ),
              const SizedBox(height: 20),

              // Time Picker UI (remains the same)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: secondaryColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(Icons.schedule, color: primaryColor),
                  title: Text(
                    'Time: ${_time.format(context)}',
                    style: TextStyle(color: primaryColor),
                  ),
                  trailing: const Icon(Icons.edit),
                  onTap: _selectTime,
                ),
              ),
              const Spacer(),

              // Submit Button
              ElevatedButton(
                onPressed:
                    _submit, // 6. The onPressed handler MUST call _submit()
                child: const Text('SAVE REMINDER'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
