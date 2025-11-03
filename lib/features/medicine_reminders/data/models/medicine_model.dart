class MedicineReminder {
  final int? id;
  final String name;
  final String dosage;
  final DateTime time;
  final bool isActive;
  final int notificationId;

  MedicineReminder({
    this.id,
    required this.name,
    required this.dosage,
    required this.time,
    this.isActive = true,
    required this.notificationId,
  });

  // --- Utility Methods for Database Interaction ---
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'time': time.toIso8601String(),
      'isActive': isActive ? 1 : 0,
      'notificationId': notificationId,
    };
  }

  factory MedicineReminder.fromMap(Map<String, dynamic> map) {
    return MedicineReminder(
      id: map['id'] as int?,
      name: map['name'] as String,
      dosage: map['dosage'] as String,
      time: DateTime.parse(map['time'] as String),
      isActive: map['isActive'] == 1,
      notificationId: map['notificationId'] as int,
    );
  }

  MedicineReminder copyWith({
    int? id,
    String? name,
    String? dosage,
    DateTime? time,
    bool? isActive,
    int? notificationId,
  }) {
    return MedicineReminder(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      time: time ?? this.time,
      isActive: isActive ?? this.isActive,
      notificationId: notificationId ?? this.notificationId,
    );
  }
}
