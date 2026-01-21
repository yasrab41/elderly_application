import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:audioplayers/audioplayers.dart'; // Import AudioPlayers
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/reminder_state_notifier.dart';
import '../data/models/medicine_model.dart';

class AddReminderPage extends ConsumerStatefulWidget {
  final MedicineReminder? reminderToEdit;
  const AddReminderPage({super.key, this.reminderToEdit});

  @override
  ConsumerState<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends ConsumerState<AddReminderPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  List<TimeOfDay> _times = [];

  // --- NEW STATE VARIABLES ---
  String _selectedSound = 'normal';
  bool _vibrationEnabled = true;
  final AudioPlayer _audioPlayer = AudioPlayer(); // To preview sound

  bool get isEditMode => widget.reminderToEdit != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      final reminder = widget.reminderToEdit!;
      _nameController.text = reminder.name;
      _dosageController.text = reminder.dosage;
      _startDate = reminder.startDate;
      _endDate = reminder.endDate;
      _times = reminder.times.map((timeStr) {
        final parts = timeStr.split(':');
        return TimeOfDay(
            hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }).toList();
      // Load settings
      _selectedSound = reminder.soundType;
      _vibrationEnabled = reminder.isVibration;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // --- SOUND PREVIEW LOGIC ---
  void _previewFeedback(String type) async {
    if (_vibrationEnabled) {
      type == 'loud'
          ? HapticFeedback.heavyImpact()
          : HapticFeedback.mediumImpact();
    }
    String soundFile =
        type == 'loud' ? 'medicine_voice.mp3' : 'normal_sound.mp3';
    await _audioPlayer.play(AssetSource('sounds/$soundFile'));
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _times.isNotEmpty) {
      final timeStrings = _times.map((time) {
        return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      }).toList();

      if (isEditMode) {
        final updatedReminder = widget.reminderToEdit!.copyWith(
          name: _nameController.text,
          dosage: _dosageController.text,
          times: timeStrings,
          startDate: _startDate,
          endDate: _endDate,
          soundType: _selectedSound,
          isVibration: _vibrationEnabled,
        );
        ref.read(remindersProvider.notifier).updateReminder(updatedReminder);
      } else {
        ref.read(remindersProvider.notifier).addReminder(
              name: _nameController.text,
              dosage: _dosageController.text,
              times: timeStrings,
              startDate: _startDate,
              endDate: _endDate,
              soundType: _selectedSound,
              isVibration: _vibrationEnabled,
            );
      }
      Navigator.of(context).pop();
    } else if (_times.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one time.')),
      );
    }
  }

  // --- WIDGET BUILDERS ---

  Widget _buildSoundBox(String label, IconData icon, String value,
      Color primaryColor, Color accentColor) {
    bool isSel = _selectedSound == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedSound = value);
          _previewFeedback(value);
        },
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: isSel ? accentColor : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isSel ? primaryColor : Colors.grey.shade300, width: 2),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: isSel ? primaryColor : Colors.grey),
            const SizedBox(height: 5),
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSel ? primaryColor : Colors.grey)),
          ]),
        ),
      ),
    );
  }

  // ... [Keep existing helper methods like _inputDecoration, _selectDate, _selectTime] ...
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Define helper colors based on theme
    final primary = theme.colorScheme.primary;
    final accent = theme.colorScheme.secondary.withOpacity(0.1);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Reminder' : 'Add New Reminder'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // [Existing Name Field]
              Text('Medicine Name',
                  style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Enter medicine name'),
                validator: (val) =>
                    (val == null || val.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 20),

              // [Existing Dosage Field]
              Text('Dosage',
                  style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dosageController,
                decoration: _inputDecoration('e.g., 1 tablet'),
                validator: (val) =>
                    (val == null || val.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 20),

              // [Existing Times Field] (Simplified for brevity)
              Text('Times',
                  style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing:
                          8, // Added runSpacing for better multiline layout
                      children: _times.map((time) {
                        return Chip(
                          label: Text(
                            time.format(context),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: primary),
                          ),
                          // 🟢 RESTORED DELETE LOGIC HERE
                          onDeleted: () {
                            setState(() {
                              _times.remove(time);
                            });
                          },
                          // 🟢 RESTORED COLORS HERE
                          backgroundColor:
                              theme.colorScheme.secondary.withOpacity(0.15),
                          deleteIconColor: primary.withOpacity(0.7),
                        );
                      }).toList(),
                    ),
                    TextButton.icon(
                      icon: Icon(Icons.add, color: primary),
                      label: Text("Add Time", style: TextStyle(color: primary)),
                      onPressed: () => _selectTime(context),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- NEW SECTION: SOUND SETTINGS ---
              Text('Notification Sound',
                  style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildSoundBox(
                      "Ring", Icons.notifications, "normal", primary, accent),
                  const SizedBox(width: 15),
                  _buildSoundBox("Voice", Icons.notifications_active, "loud",
                      primary, accent),
                ],
              ),
              const SizedBox(height: 15),

              // --- NEW SECTION: VIBRATION ---
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Icon(Icons.vibration, color: primary),
                      const SizedBox(width: 10),
                      const Text("Vibration",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ]),
                    Switch(
                      value: _vibrationEnabled,
                      activeColor: primary,
                      onChanged: (val) =>
                          setState(() => _vibrationEnabled = val),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // [Existing Dates Section]
              Row(children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const Text("Start Date",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      InkWell(
                          onTap: () => _selectDate(context, true),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(
                                DateFormat('MM/dd/yyyy').format(_startDate)),
                          ))
                    ])),
                const SizedBox(width: 15),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const Text("End Date",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      InkWell(
                          onTap: () => _selectDate(context, false),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8)),
                            child:
                                Text(DateFormat('MM/dd/yyyy').format(_endDate)),
                          ))
                    ])),
              ]),

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
