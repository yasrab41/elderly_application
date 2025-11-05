import 'dart:convert'; // Required for encoding/decoding the list of times

class MedicineReminder {
  final int? id;
  final String name;
  final String dosage;

  // --- NEW FIELDS ---
  // Store times as a list of 'HH:mm' strings (e.g., "08:00", "20:00")
  final List<String> times;
  final DateTime startDate;
  final DateTime endDate;
  // --- END NEW FIELDS ---

  final bool isActive;
  // We'll use the reminder ID + time index for unique notification IDs,
  // so 'notificationId' is no longer needed in the model itself.

  MedicineReminder({
    this.id,
    required this.name,
    required this.dosage,
    required this.times,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
  });

  // --- Utility Methods for Database Interaction ---
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'times':
          jsonEncode(times), // Encode list of strings into a single JSON string
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive ? 1 : 0,
    };
  }

  factory MedicineReminder.fromMap(Map<String, dynamic> map) {
    return MedicineReminder(
      id: map['id'] as int?,
      name: map['name'] as String,
      dosage: map['dosage'] as String,
      // Decode the JSON string back into a List<String>
      times: List<String>.from(jsonDecode(map['times'] as String)),
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      isActive: map['isActive'] == 1,
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
  }) {
    return MedicineReminder(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      times: times ?? this.times,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
    );
  }
}
