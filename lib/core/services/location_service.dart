import 'package:geolocator/geolocator.dart';

/// Thrown when the device's location service (GPS) is turned off.
class LocationServiceDisabledException implements Exception {}

/// Thrown when the user denies the location permission once.
class LocationPermissionDeniedException implements Exception {}

/// Thrown when the user has permanently denied the location permission
/// (must be re-enabled from system settings).
class LocationPermissionDeniedForeverException implements Exception {}

/// Shared helper for anything that needs "find things near me" behavior.
/// Used by Bus Stops today, and will be reused by Hospitals and Markets.
class LocationService {
  /// Gets the user's current position, handling permission/service checks.
  Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceDisabledException();
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationPermissionDeniedException();
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationPermissionDeniedForeverException();
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  /// Straight-line distance in meters between two coordinates.
  double distanceInMeters({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Friendly distance label, e.g. "350 m" or "1.2 km".
  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  /// Rough walking-time estimate at an elderly-friendly pace (~4.5 km/h).
  String formatWalkingTime(double meters) {
    const walkingSpeedMetersPerMinute = 75;
    final minutes = (meters / walkingSpeedMetersPerMinute).ceil();
    if (minutes < 1) return '1 min';
    return '$minutes min';
  }
}
