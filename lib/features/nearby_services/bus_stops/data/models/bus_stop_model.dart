/// A single ESHOT (İzmir) bus stop, sourced from the İzmir Metropolitan
/// Municipality open data portal.
class BusStopModel {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final List<String> lines;

  const BusStopModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.lines,
  });

  factory BusStopModel.fromMap(Map<String, dynamic> map) {
    return BusStopModel(
      id: map['id'] as int,
      name: map['name'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      lines: (map['lines'] as String)
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'lines': lines.join(','),
    };
  }
}

/// A bus stop paired with the user's current distance to it. Computed at
/// runtime from the user's live location — never persisted.
class BusStopWithDistance {
  final BusStopModel stop;
  final double distanceMeters;

  const BusStopWithDistance({
    required this.stop,
    required this.distanceMeters,
  });
}
