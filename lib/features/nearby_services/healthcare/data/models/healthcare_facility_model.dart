/// Which of İzmir's open-data health facility feeds this record came from.
enum HealthcareCategory { hospital, familyHealthCenter, pharmacy }

/// A single healthcare facility, sourced from İzmir Metropolitan
/// Municipality's open data API (hospitals, family health centers) or the
/// live on-duty pharmacy feed.
class HealthcareFacilityModel {
  final String id;
  final HealthcareCategory category;
  final String name;
  final String district;
  final String neighborhood;
  final String? street;
  final String? buildingNo;
  final double latitude;
  final double longitude;
  final String? phone;
  final String? address;
  final String? notes;
  final bool isOnDuty;

  const HealthcareFacilityModel({
    required this.id,
    required this.category,
    required this.name,
    required this.district,
    required this.neighborhood,
    required this.latitude,
    required this.longitude,
    this.street,
    this.buildingNo,
    this.phone,
    this.address,
    this.notes,
    this.isOnDuty = false,
  });

  /// A human-readable address, preferring a full address string (pharmacies)
  /// and falling back to composing one from street/neighborhood/district.
  String displayAddress() {
    if (address != null && address!.trim().isNotEmpty) {
      return address!.trim();
    }
    final parts = <String>[];
    if (street != null && street!.trim().isNotEmpty) {
      final buildingSuffix =
          (buildingNo != null && buildingNo!.trim().isNotEmpty)
              ? ' No:${buildingNo!.trim()}'
              : '';
      parts.add('${street!.trim()}$buildingSuffix');
    }
    if (neighborhood.trim().isNotEmpty) parts.add(neighborhood.trim());
    if (district.trim().isNotEmpty) parts.add(district.trim());
    return parts.join(', ');
  }

  factory HealthcareFacilityModel.fromMap(Map<String, dynamic> map) {
    return HealthcareFacilityModel(
      id: map['id'] as String,
      category: HealthcareCategory.values.firstWhere(
        (c) => c.name == map['category'],
        orElse: () => HealthcareCategory.hospital,
      ),
      name: map['name'] as String,
      district: map['district'] as String? ?? '',
      neighborhood: map['neighborhood'] as String? ?? '',
      street: map['street'] as String?,
      buildingNo: map['buildingNo'] as String?,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      notes: map['notes'] as String?,
      isOnDuty: (map['isOnDuty'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category.name,
      'name': name,
      'district': district,
      'neighborhood': neighborhood,
      'street': street,
      'buildingNo': buildingNo,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'address': address,
      'notes': notes,
      'isOnDuty': isOnDuty ? 1 : 0,
    };
  }
}

/// A facility paired with the user's current distance to it.
class HealthcareFacilityWithDistance {
  final HealthcareFacilityModel facility;
  final double distanceMeters;

  const HealthcareFacilityWithDistance({
    required this.facility,
    required this.distanceMeters,
  });
}
