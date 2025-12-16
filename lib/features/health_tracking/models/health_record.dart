class HealthRecord {
  final int? id;
  final String userId;
  final String type; // 'bp', 'sugar', 'weight', 'sleep', 'heart', 'steps'
  final double value1; // Main value (or Systolic for BP)
  final double? value2; // Diastolic for BP (null for others)
  final DateTime timestamp;
  final String? note;

  HealthRecord({
    this.id,
    required this.userId,
    required this.type,
    required this.value1,
    this.value2,
    required this.timestamp,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'value1': value1,
      'value2': value2,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
    };
  }

  factory HealthRecord.fromMap(Map<String, dynamic> map) {
    return HealthRecord(
      id: map['id'],
      userId: map['userId'],
      type: map['type'],
      value1: map['value1'],
      value2: map['value2'],
      timestamp: DateTime.parse(map['timestamp']),
      note: map['note'],
    );
  }
}
