import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/reminder_state_notifier.dart';

class AddReminderPage extends ConsumerStatefulWidget {
  const AddReminderPage({super.key});

  @override
  ConsumerState<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends ConsumerState<AddReminderPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  // Stores the times the user picks
  final List<TimeOfDay> _times = [];

  // Helper for your brown theme
  InputDecoration _inputDecoration(String label) {
    final theme = Theme.of(context);
    return InputDecoration(
      hintText: label,
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
          // Ensure end date is always after start date
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
        // Sort times chronologically
        _times.sort(
            (a, b) => (a.hour * 60 + a.minute) - (b.hour * 60 + b.minute));
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _times.isNotEmpty) {
      // Convert List<TimeOfDay> to List<String> ("HH:mm")
      final timeStrings = _times.map((time) {
        return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      }).toList();

      ref.read(remindersProvider.notifier).addReminder(
            name: _nameController.text,
            dosage: _dosageController.text,
            times: timeStrings,
            startDate: _startDate,
            endDate: _endDate,
          );
      Navigator.of(context).pop();
    } else if (_times.isEmpty) {
      // Show error if no times are added
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
    // Use a light background that complements the brown theme
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Add New Reminder',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        foregroundColor: theme.colorScheme.secondary, // Brown text/icons
        actions: [
          IconButton(
            icon: const Icon(
              Icons.close,
            ),
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

              Text('Times',
                  style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              const SizedBox(height: 8),

              // --- List of Times ---
              Container(
                padding: const EdgeInsets.all(8),
                // decoration: BoxDecoration(
                //     color: Colors.white,
                //     borderRadius: BorderRadius.circular(12),
                //     border: Border.all(
                //         color: theme.colorScheme.secondary.withOpacity(0.5))),
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

              // --- Start & End Dates ---
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
                  backgroundColor:
                      theme.colorScheme.secondary, // Use your brown theme color
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Add Reminder',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
