/// Which market category this record belongs to.
enum MarketCategory {
  supermarket,
  groceryConvenience,
  bakery,
  butcher,
  greengrocer,
  weeklyBazaar,
}

/// A single market/shop, sourced either from OpenStreetMap (supermarkets,
/// grocery/convenience stores, bakeries, butchers, greengrocers) or from
/// İzmir Metropolitan Municipality's open data (weekly neighborhood bazaars).
class MarketFacilityModel {
  final String id;
  final MarketCategory category;
  final String name;
  final String district;
  final String neighborhood;
  final String? street;
  final String? buildingNo;
  final double latitude;
  final double longitude;
  final String? notes;

  /// ISO weekday numbers (1 = Monday ... 7 = Sunday) this bazaar runs on.
  /// Empty for all non-bazaar categories.
  final List<int> scheduleDays;

  const MarketFacilityModel({
    required this.id,
    required this.category,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.district = '',
    this.neighborhood = '',
    this.street,
    this.buildingNo,
    this.notes,
    this.scheduleDays = const [],
  });

  String displayAddress() {
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

  factory MarketFacilityModel.fromMap(Map<String, dynamic> map) {
    final daysRaw = map['scheduleDays'] as String? ?? '';
    return MarketFacilityModel(
      id: map['id'] as String,
      category: MarketCategory.values.firstWhere(
        (c) => c.name == map['category'],
        orElse: () => MarketCategory.supermarket,
      ),
      name: map['name'] as String,
      district: map['district'] as String? ?? '',
      neighborhood: map['neighborhood'] as String? ?? '',
      street: map['street'] as String?,
      buildingNo: map['buildingNo'] as String?,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      notes: map['notes'] as String?,
      scheduleDays: daysRaw.isEmpty
          ? const []
          : daysRaw.split(',').map((e) => int.parse(e)).toList(),
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
      'notes': notes,
      'scheduleDays': scheduleDays.join(','),
    };
  }
}

/// A market paired with the user's current distance to it.
class MarketFacilityWithDistance {
  final MarketFacilityModel facility;
  final double distanceMeters;

  const MarketFacilityWithDistance({
    required this.facility,
    required this.distanceMeters,
  });
}
