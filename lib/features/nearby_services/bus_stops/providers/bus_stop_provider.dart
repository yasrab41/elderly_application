import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elderly_prototype_app/core/constants.dart';
import 'package:elderly_prototype_app/core/services/location_service.dart';
import '../data/models/bus_stop_model.dart';
import '../data/services/bus_stop_favorites_service.dart';
import '../data/services/bus_stop_repository.dart';

class BusStopsState {
  final bool isLoading;
  final String? errorMessage;
  final List<BusStopWithDistance> stops;
  final DateTime? lastUpdated;

  const BusStopsState({
    this.isLoading = false,
    this.errorMessage,
    this.stops = const [],
    this.lastUpdated,
  });

  BusStopsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<BusStopWithDistance>? stops,
    DateTime? lastUpdated,
    bool clearError = false,
  }) {
    return BusStopsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      stops: stops ?? this.stops,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class BusStopsNotifier extends StateNotifier<BusStopsState> {
  BusStopsNotifier() : super(const BusStopsState());

  // Only show the closest stops rather than the entire İzmir-wide dataset —
  // showing thousands of stops at once is overwhelming and not useful.
  static const int _maxResultsToShow = 20;

  final BusStopRepository _repository = BusStopRepository();
  final LocationService _locationService = LocationService();
  final BusStopFavoritesService _favoritesService = BusStopFavoritesService();

  Set<int> _favoriteIds = {};

  Future<void> loadNearbyStops({bool forceRefresh = false}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      _favoriteIds = await _favoritesService.getFavoriteIds();
      final position = await _locationService.getCurrentPosition();
      final allStops = await _repository.getStops(forceRefresh: forceRefresh);

      final withDistance = allStops.map((stop) {
        final distance = _locationService.distanceInMeters(
          startLatitude: position.latitude,
          startLongitude: position.longitude,
          endLatitude: stop.latitude,
          endLongitude: stop.longitude,
        );
        return BusStopWithDistance(stop: stop, distanceMeters: distance);
      }).toList();

      _sortByFavoriteThenDistance(withDistance);
      final limited = _limitResults(withDistance);

      state = state.copyWith(
        isLoading: false,
        stops: limited,
        lastUpdated: DateTime.now(),
      );
    } on LocationServiceDisabledException {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AppStrings.locationServiceDisabledMessage,
      );
    } on LocationPermissionDeniedException {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AppStrings.locationPermissionDeniedMessage,
      );
    } on LocationPermissionDeniedForeverException {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AppStrings.locationPermissionDeniedForeverMessage,
      );
    } on BusStopDataUnavailableException {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AppStrings.busStopsDataUnavailableMessage,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AppStrings.busStopsGenericError,
      );
    }
  }

  bool isFavorite(int stopId) => _favoriteIds.contains(stopId);

  Future<void> toggleFavorite(int stopId) async {
    if (_favoriteIds.contains(stopId)) {
      _favoriteIds.remove(stopId);
    } else {
      _favoriteIds.add(stopId);
    }
    await _favoritesService.saveFavoriteIds(_favoriteIds);

    final resorted = List<BusStopWithDistance>.from(state.stops);
    _sortByFavoriteThenDistance(resorted);
    state = state.copyWith(stops: resorted);
  }

  void _sortByFavoriteThenDistance(List<BusStopWithDistance> stops) {
    stops.sort((a, b) {
      final aFav = _favoriteIds.contains(a.stop.id);
      final bFav = _favoriteIds.contains(b.stop.id);
      if (aFav != bFav) return aFav ? -1 : 1;
      return a.distanceMeters.compareTo(b.distanceMeters);
    });
  }

  /// Keeps every favorited stop (however far) plus the nearest
  /// [_maxResultsToShow] stops overall. Since [stops] is already sorted
  /// favorites-first-then-distance, favorites always sit at the front.
  List<BusStopWithDistance> _limitResults(List<BusStopWithDistance> stops) {
    final favoriteCount =
        stops.where((s) => _favoriteIds.contains(s.stop.id)).length;
    final cap =
        favoriteCount > _maxResultsToShow ? favoriteCount : _maxResultsToShow;
    return stops.take(cap).toList();
  }
}

final busStopsProvider =
    StateNotifierProvider<BusStopsNotifier, BusStopsState>((ref) {
  return BusStopsNotifier();
});
