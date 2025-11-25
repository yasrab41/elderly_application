class EmergencyContact {
  final int? id;
  final String userId; // Links contact to specific user
  final String name;
  final String phoneNumber;
  final bool isPrimary; // Determines who gets the direct call

  EmergencyContact({
    this.id,
    required this.userId,
    required this.name,
    required this.phoneNumber,
    this.isPrimary = false,
  });

  // Convert to Map for Database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'phone_number': phoneNumber,
      'is_primary': isPrimary ? 1 : 0,
    };
  }

  // Create Object from Database Map
  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      id: map['id'] as int,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      phoneNumber: map['phone_number'] as String,
      isPrimary: map['is_primary'] == 1,
    );
  }

  EmergencyContact copyWith({
    int? id,
    String? userId,
    String? name,
    String? phoneNumber,
    bool? isPrimary,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}
