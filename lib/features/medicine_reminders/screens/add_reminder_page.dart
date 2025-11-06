import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ⭐️ FIXED: Riverpod import was missing
import 'package:intl/intl.dart';
import '../services/reminder_state_notifier.dart';
import '../data/models/medicine_model.dart';

class AddReminderPage extends ConsumerStatefulWidget {
  // ⭐️ FIXED: Needs ConsumerStatefulWidget from Riverpod
  // 2. Add optional reminder field
  final MedicineReminder? reminderToEdit;

  const AddReminderPage({super.key, this.reminderToEdit});

  @override
  ConsumerState<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends ConsumerState<AddReminderPage> {
  // ⭐️ FIXED: Needs ConsumerState from Riverpod
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  List<TimeOfDay> _times = [];

  // 4. Check if we are in "Edit Mode"
  bool get isEditMode => widget.reminderToEdit != null;

  @override
  void initState() {
    super.initState();
    // 5. Pre-fill fields if we are in edit mode
    if (isEditMode) {
      final reminder = widget.reminderToEdit!;
      _nameController.text = reminder.name;
      _dosageController.text = reminder.dosage;
      _startDate = reminder.startDate;
      _endDate = reminder.endDate;
      // Convert List<String> back to List<TimeOfDay>
      _times = reminder.times.map((timeStr) {
        final parts = timeStr.split(':');
        return TimeOfDay(
            hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }).toList();
    }
  }

  // (Helper for input decoration remains the same)
  InputDecoration _inputDecoration(String label) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: theme.colorScheme.secondary),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: theme.colorScheme.secondary.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: theme.colorScheme.secondary.withOpacity(0.5)),
      ),
    );
  }

  // (Date/Time selection methods remain the same)
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _times.add(picked);
        _times.sort(
            (a, b) => (a.hour * 60 + a.minute) - (b.hour * 60 + b.minute));
      });
    }
  }

  // 6. --- SUBMIT METHOD (HEAVILY MODIFIED) ---
  void _submit() {
    if (_formKey.currentState!.validate() && _times.isNotEmpty) {
      // Convert List<TimeOfDay> to List<String> ("HH:mm")
      final timeStrings = _times.map((time) {
        return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      }).toList();

      if (isEditMode) {
        // --- UPDATE LOGIC ---
        // Create an updated reminder object, keeping the original ID
        final updatedReminder = widget.reminderToEdit!.copyWith(
          name: _nameController.text,
          dosage: _dosageController.text,
          times: timeStrings,
          startDate: _startDate,
          endDate: _endDate,
        );
        // Call the new updateReminder method
        ref.read(remindersProvider.notifier).updateReminder(updatedReminder);
      } else {
        // --- ADD LOGIC (Original) ---
        ref.read(remindersProvider.notifier).addReminder(
              name: _nameController.text,
              dosage: _dosageController.text,
              times: timeStrings,
              startDate: _startDate,
              endDate: _endDate,
            );
      }
      Navigator.of(context).pop(); // Go back after add or update
    } else if (_times.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add at least one time.'),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.primary.withOpacity(0.05),
      appBar: AppBar(
        // 7. Update AppBar title
        title: Text(isEditMode ? 'Edit Reminder' : 'Add New Reminder'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: theme.colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // (TextFormFields for Name and Dosage remain the same)
              Text('Medicine Name',
                  style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Enter medicine name'),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Cannot be empty' : null,
              ),
              const SizedBox(height: 20),
              Text('Dosage',
                  style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dosageController,
                decoration: _inputDecoration('e.g., 1 tablet, 2 capsules'),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Cannot be empty' : null,
              ),
              const SizedBox(height: 20),

              // (Times section remains the same)
              Text('Times',
                  style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: theme.colorScheme.secondary.withOpacity(0.5))),
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: _times.map((time) {
                    return Chip(
                      label: Text(time.format(context),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary)),
                      onDeleted: () {
                        setState(() {
                          _times.remove(time);
                        });
                      },
                      backgroundColor:
                          theme.colorScheme.secondary.withOpacity(0.2),
                      deleteIconColor:
                          theme.colorScheme.primary.withOpacity(0.7),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                icon: Icon(Icons.add_circle_outline,
                    color: theme.colorScheme.primary),
                label: Text('Add Time',
                    style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold)),
                onPressed: () => _selectTime(context),
              ),
              const SizedBox(height: 20),

              // (Date selection rows remain the same)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Start Date',
                            style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        const SizedBox(height: 8),
                        TextFormField(
                          readOnly: true,
                          controller: TextEditingController(
                              text:
                                  DateFormat('MM/dd/yyyy').format(_startDate)),
                          decoration: _inputDecoration('Start Date').copyWith(
                              suffixIcon: Icon(Icons.calendar_today_outlined,
                                  color: theme.colorScheme.secondary)),
                          onTap: () => _selectDate(context, true),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('End Date',
                            style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        const SizedBox(height: 8),
                        TextFormField(
                          readOnly: true,
                          controller: TextEditingController(
                              text: DateFormat('MM/dd/yyyy').format(_endDate)),
                          decoration: _inputDecoration('End Date').copyWith(
                              suffixIcon: Icon(Icons.calendar_today_outlined,
                                  color: theme.colorScheme.secondary)),
                          onTap: () => _selectDate(context, false),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                // 8. Update button text
                child: Text(isEditMode ? 'Update Reminder' : 'Add Reminder',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
