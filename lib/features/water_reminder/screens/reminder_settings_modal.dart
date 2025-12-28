import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for Haptics
import 'package:audioplayers/audioplayers.dart'; // Add this to pubspec.yaml

class ReminderSettingsModal extends StatefulWidget {
  final Function(String sound, bool vibration, int interval) onSave;
  final String currentSound;
  final bool currentVibration;
  final int currentInterval;

  const ReminderSettingsModal({
    Key? key,
    required this.onSave,
    this.currentSound = 'normal',
    this.currentVibration = true,
    this.currentInterval = 1,
  }) : super(key: key);

  @override
  _ReminderSettingsModalState createState() => _ReminderSettingsModalState();
}

class _ReminderSettingsModalState extends State<ReminderSettingsModal> {
  late String _selectedSound;
  late bool _vibrationEnabled;
  late int _selectedInterval;
  final AudioPlayer _audioPlayer = AudioPlayer();

  final Color _primaryColor = const Color(0xFF4A90E2);
  final Color _accentColor = const Color(0xFFE3F2FD);
  final Color _textColor = const Color(0xFF333333);

  @override
  void initState() {
    super.initState();
    _selectedSound = widget.currentSound;
    _vibrationEnabled = widget.currentVibration;
    _selectedInterval = widget.currentInterval;
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // This stops the sound and frees up memory
    super.dispose();
  }

  // Helper to preview sound and vibration for the user
  Future<void> _previewFeedback(String type) async {
    if (_vibrationEnabled) {
      if (type == 'loud') {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.mediumImpact();
      }
    }

    String soundFile = type == 'loud' ? 'loud_sound.mp3' : 'normal_sound.mp3';
    await _audioPlayer.play(AssetSource('sounds/$soundFile'));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Settings",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _textColor)),
              IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 20),
          Text("Remind me every:",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _textColor)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [1, 2, 3, 4].map((hours) {
              bool isSelected = _selectedInterval == hours;
              return GestureDetector(
                onTap: () => setState(() => _selectedInterval = hours),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? _primaryColor : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text("$hours hour(s)",
                      style: TextStyle(
                          color: isSelected ? Colors.white : _textColor,
                          fontWeight: FontWeight.w600)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 25),
          Text("Sound:",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _textColor)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildSoundOption("Normal", Icons.volume_up, "normal"),
              const SizedBox(width: 15),
              _buildSoundOption("Loud", Icons.volume_up, "loud"),
            ],
          ),
          const SizedBox(height: 25),
          Text("Vibration:",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _textColor)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _accentColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _primaryColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.vibration, color: _primaryColor, size: 28),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Vibration",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _primaryColor,
                              fontSize: 16)),
                      Text("Vibrate on reminder",
                          style: TextStyle(
                              color: _primaryColor.withOpacity(0.7),
                              fontSize: 12)),
                    ],
                  ),
                ),
                Switch(
                  value: _vibrationEnabled,
                  activeColor: _primaryColor,
                  onChanged: (val) => setState(() => _vibrationEnabled = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                widget.onSave(
                    _selectedSound, _vibrationEnabled, _selectedInterval);
                Navigator.pop(context);
              },
              child: const Text("Save",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundOption(String label, IconData icon, String value) {
    bool isSelected = _selectedSound == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedSound = value);
          _previewFeedback(value); // Play preview when selected
        },
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: isSelected ? _accentColor : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isSelected ? _primaryColor : Colors.grey.shade300,
                width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 32,
                  color: isSelected ? _primaryColor : Colors.grey.shade600),
              const SizedBox(height: 8),
              Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          isSelected ? _primaryColor : Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }
}
