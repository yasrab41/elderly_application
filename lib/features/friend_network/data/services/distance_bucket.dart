import 'package:elderly_prototype_app/core/constants.dart';

/// Deliberately coarse — unlike Bus Stops/Healthcare/Markets, showing exact
/// distance between two people is a real safety risk (repeated precise
/// readings can be used to triangulate someone's home). Buckets only.
String distanceBucketLabel(double? meters) {
  if (meters == null) return AppStrings.distanceUnknown;
  if (meters < 1000) return AppStrings.distanceVeryClose;
  if (meters < 5000) return AppStrings.distanceNearby;
  if (meters < 15000) return AppStrings.distanceInIzmir;
  return AppStrings.distanceFurtherAway;
}
