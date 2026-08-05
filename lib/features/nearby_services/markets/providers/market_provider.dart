import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elderly_prototype_app/core/constants.dart';
import 'package:elderly_prototype_app/core/services/location_service.dart';
import '../data/models/market_facility_model.dart';
import '../data/services/market_favorites_service.dart';
import '../data/services/market_repository.dart';

class MarketState {
  final bool isLoading;
  final String? errorMessage;
  final List<MarketFacilityWithDistance> facilities;
  final MarketCategory? selectedCategory; // null = All
  final String searchQuery;
  final DateTime? lastUpdated;

  const MarketState({
    this.isLoading = false,
    this.errorMessage,
    this.facilities = const [],
    this.selectedCategory,
    this.searchQuery = '',
    this.lastUpdated,
  });

  MarketState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<MarketFacilityWithDistance>? facilities,
    MarketCategory? selectedCategory,
    bool clearCategory = false,
    String? searchQuery,
    DateTime? lastUpdated,
    bool clearError = false,
  }) {
    return MarketState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      facilities: facilities ?? this.facilities,
      selectedCategory:
          clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      searchQuery: searchQuery ?? this.searchQuery,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class MarketNotifier extends StateNotifier<MarketState> {
  MarketNotifier() : super(const MarketState());

  static const int _maxResultsToShow = 20;

  final MarketRepository _repository = MarketRepository();
  final LocationService _locationService = LocationService();
  final MarketFavoritesService _favoritesService = MarketFavoritesService();

  Set<String> _favoriteIds = {};

  Future<void> loadNearby({bool forceRefresh = false}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      _favoriteIds = await _favoritesService.getFavoriteIds();
      final position = await _locationService.getCurrentPosition();

      var bazaars = <MarketFacilityModel>[];
      var shops = <MarketFacilityModel>[];

      try {
        bazaars = await _repository.getBazaars(forceRefresh: forceRefresh);
      } catch (_) {}
      try {
        shops = await _repository.getNearbyShops(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      } catch (_) {}

      final combined = [...bazaars, ...shops];
      if (combined.isEmpty) {
        throw MarketDataUnavailableException();
      }

      final withDistance = combined.map((facility) {
        final distance = _locationService.distanceInMeters(
          startLatitude: position.latitude,
          startLongitude: position.longitude,
          endLatitude: facility.latitude,
          endLongitude: facility.longitude,
        );
        return MarketFacilityWithDistance(
            facility: facility, distanceMeters: distance);
      }).toList();

      state = state.copyWith(
        isLoading: false,
        facilities: withDistance,
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
    } on MarketDataUnavailableException {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AppStrings.marketsDataUnavailableMessage,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AppStrings.marketsGenericError,
      );
    }
  }

  void setCategory(MarketCategory? category) {
    state = state.copyWith(
      selectedCategory: category,
      clearCategory: category == null,
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  bool isFavorite(String id) => _favoriteIds.contains(id);

  Future<void> toggleFavorite(String id) async {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    await _favoritesService.saveFavoriteIds(_favoriteIds);
    state = state.copyWith();
  }

  List<MarketFacilityWithDistance> get visibleFacilities {
    var list = state.facilities.where((item) {
      if (state.selectedCategory != null &&
          item.facility.category != state.selectedCategory) {
        return false;
      }
      final query = state.searchQuery.trim().toLowerCase();
      if (query.isNotEmpty &&
          !item.facility.name.toLowerCase().contains(query)) {
        return false;
      }
      return true;
    }).toList();

    list.sort((a, b) {
      final aFav = _favoriteIds.contains(a.facility.id);
      final bFav = _favoriteIds.contains(b.facility.id);
      if (aFav != bFav) return aFav ? -1 : 1;
      return a.distanceMeters.compareTo(b.distanceMeters);
    });

    final favoriteCount =
        list.where((item) => _favoriteIds.contains(item.facility.id)).length;
    final cap =
        favoriteCount > _maxResultsToShow ? favoriteCount : _maxResultsToShow;
    return list.take(cap).toList();
  }
}

final marketProvider =
    StateNotifierProvider<MarketNotifier, MarketState>((ref) {
  return MarketNotifier();
});
