import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class ReminderSettingsModal extends StatefulWidget {
  final Function({
    required String startMode, // 'now' or 'custom'
    required String customStartTime,
    required double intervalMinutes,
    required String activeStart,
    required String activeEnd,
    required String sound,
    required bool vibration,
  }) onSave;

  final String currentSound;
  final bool currentVibration;
  final double currentInterval;
  final String currentActiveStart;
  final String currentActiveEnd;

  const ReminderSettingsModal({
    super.key,
    required this.onSave,
    this.currentSound = 'normal',
    this.currentVibration = true,
    this.currentInterval = 60,
    this.currentActiveStart = "09:00",
    this.currentActiveEnd = "21:00",
  });

  @override
  State<ReminderSettingsModal> createState() => _ReminderSettingsModalState();
}

class _ReminderSettingsModalState extends State<ReminderSettingsModal> {
  late String _startMode = 'now';
  late String _customStartTime = "09:00";
  late double _selectedInterval;
  late String _selectedSound;
  late bool _vibrationEnabled;

  late double _activeStartHour;
  late double _activeEndHour;

  final AudioPlayer _audioPlayer = AudioPlayer();
  final Color _primaryColor = const Color(0xFF4A90E2);
  final Color _accentColor = const Color(0xFFE3F2FD);

  @override
  void initState() {
    super.initState();
    _selectedInterval = widget.currentInterval;
    _selectedSound = widget.currentSound;
    _vibrationEnabled = widget.currentVibration;

    // Parse the start/end times correctly
    try {
      _activeStartHour = double.parse(widget.currentActiveStart.split(':')[0]);
      _activeEndHour = double.parse(widget.currentActiveEnd.split(':')[0]);
    } catch (e) {
      _activeStartHour = 9.0;
      _activeEndHour = 21.0;
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _previewFeedback(String type) async {
    if (_vibrationEnabled) {
      type == 'loud'
          ? HapticFeedback.heavyImpact()
          : HapticFeedback.mediumImpact();
    }
    String soundFile = type == 'loud' ? 'loud_sound.mp3' : 'normal_sound.mp3';
    await _audioPlayer.play(AssetSource('sounds/$soundFile'));
  }

  String _formatHour(double hour) =>
      "${hour.toInt().toString().padLeft(2, '0')}:00";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      maintainBottomViewPadding: true,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Reminder Settings",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

                  // 2. USE THIS BUTTON CODE
                  // We wrap it in a Material to ensure the tap 'splash' is visible
                  // and use 'InkWell' or strictly 'IconButton' for clear hit testing.
                  Material(
                    color: Colors.transparent,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      iconSize: 28, // Slightly larger for easier tapping
                      splashRadius:
                          24, // Reduces the ripple size to look cleaner
                      onPressed: () {
                        // Navigator.pop(context) is usually sufficient.
                        // rootNavigator: true is safer for Modals.
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 1. When to Start
              const Text("When to start:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildStartOption("Start Now", "Begin reminders immediately",
                  Icons.play_circle_outline, 'now'),
              const SizedBox(height: 10),
              _buildStartOption("Custom Start Time", "Choose when to begin",
                  Icons.access_time, 'custom'),

              if (_startMode == 'custom') ...[
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: () async {
                      TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: const TimeOfDay(hour: 9, minute: 0));
                      if (picked != null) {
                        setState(() => _customStartTime =
                            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}");
                      }
                    },
                    child: Text("Selected: $_customStartTime",
                        style: TextStyle(
                            fontSize: 18,
                            color: _primaryColor,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],

              const SizedBox(height: 25),

              // 2. Flexible Intervals
              const Text("Remind me every:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [1.0, 60.0, 90.0, 120.0, 180.0, 240.0].map((mins) {
                  bool isSelected = _selectedInterval == mins;
                  String label = mins < 60
                      ? "${mins.toInt()} min"
                      : "${(mins / 60).toStringAsFixed(mins % 60 == 0 ? 0 : 1)}h";
                  return GestureDetector(
                    onTap: () => setState(() => _selectedInterval = mins),
                    child: Container(
                      width: 100,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: isSelected ? _primaryColor : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                          child: Text(label,
                              style: TextStyle(
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold))),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 25),

              // 3. Active Hours
              const Text("Active Hours (No sleep disturbance):",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: _accentColor,
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _timeDisplay(
                            "Start Time", _formatHour(_activeStartHour)),
                        const Icon(Icons.arrow_forward, color: Colors.grey),
                        _timeDisplay("End Time", _formatHour(_activeEndHour)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text("Reminders will only work between these hours",
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text("Start Hour: ${_formatHour(_activeStartHour)}"),
              Slider(
                  value: _activeStartHour,
                  min: 0,
                  max: 23,
                  divisions: 23,
                  activeColor: _primaryColor,
                  onChanged: (v) => setState(() => _activeStartHour = v)),
              Text("End Hour: ${_formatHour(_activeEndHour)}"),
              Slider(
                  value: _activeEndHour,
                  min: 0,
                  max: 23,
                  divisions: 23,
                  activeColor: _primaryColor,
                  onChanged: (v) => setState(() => _activeEndHour = v)),

              const SizedBox(height: 25),

              // 4. Sound
              const Text("Sound:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildSoundBox("Ring", Icons.volume_up, "normal"),
                  const SizedBox(width: 15),
                  _buildSoundBox("Voice", Icons.volume_up_outlined, "loud"),
                ],
              ),

              const SizedBox(height: 30),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16))),
                  onPressed: () {
                    // Logic to determine the actual Start Time based on user selection
                    String finalStartTime;

                    if (_startMode == 'now') {
                      // If "Start Now", get the current time formatted as HH:mm
                      final now = TimeOfDay.now();
                      finalStartTime =
                          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
                    } else {
                      // If "Custom", use the time picked from the time picker
                      finalStartTime = _customStartTime;
                    }

                    widget.onSave(
                      startMode: _startMode,
                      customStartTime: _customStartTime,
                      intervalMinutes: _selectedInterval,
                      // Pass the DETERMINED start time, not the slider value
                      activeStart: finalStartTime,
                      activeEnd: _formatHour(_activeEndHour),
                      sound: _selectedSound,
                      vibration: _vibrationEnabled,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text("Start Reminder",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartOption(
      String title, String sub, IconData icon, String mode) {
    bool isSel = _startMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _startMode = mode),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
              color: isSel ? _primaryColor : Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(16),
          color: isSel ? _accentColor : Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSel ? _primaryColor : Colors.grey),
            const SizedBox(width: 15),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSel ? _primaryColor : Colors.black)),
                  Text(sub,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ])),
            if (isSel) Icon(Icons.check_circle, color: _primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundBox(String label, IconData icon, String value) {
    bool isSel = _selectedSound == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedSound = value);
          _previewFeedback(value);
        },
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            color: isSel ? _accentColor : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isSel ? _primaryColor : Colors.grey.shade300, width: 2),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: isSel ? _primaryColor : Colors.grey),
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSel ? _primaryColor : Colors.grey)),
          ]),
        ),
      ),
    );
  }

  Widget _timeDisplay(String label, String time) {
    return Column(children: [
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      const SizedBox(height: 5),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Text(time,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _primaryColor)),
      ),
    ]);
  }
}
