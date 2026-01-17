import 'dart:convert';

class MedicineReminder {
  final int? id;
  final String name;
  final String dosage;
  final List<String> times;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  // --- NEW FIELDS ---
  final String soundType; // 'normal' or 'loud'
  final bool isVibration;

  MedicineReminder({
    this.id,
    required this.name,
    required this.dosage,
    required this.times,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    // Default values
    this.soundType = 'normal',
    this.isVibration = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'times': jsonEncode(times),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive ? 1 : 0,
      // Save new fields
      'soundType': soundType,
      'isVibration': isVibration ? 1 : 0,
    };
  }

  factory MedicineReminder.fromMap(Map<String, dynamic> map) {
    return MedicineReminder(
      id: map['id'] as int?,
      name: map['name'] as String,
      dosage: map['dosage'] as String,
      times: List<String>.from(jsonDecode(map['times'] as String)),
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      isActive: map['isActive'] == 1,
      // Load new fields with fallbacks
      soundType: map['soundType'] ?? 'normal',
      isVibration: (map['isVibration'] ?? 1) == 1,
    );
  }

  MedicineReminder copyWith({
    int? id,
    String? name,
    String? dosage,
    List<String>? times,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    String? soundType,
    bool? isVibration,
  }) {
    return MedicineReminder(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      times: times ?? this.times,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      soundType: soundType ?? this.soundType,
      isVibration: isVibration ?? this.isVibration,
    );
  }
}
