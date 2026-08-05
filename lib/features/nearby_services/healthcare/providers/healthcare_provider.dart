import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elderly_prototype_app/core/constants.dart';
import 'package:elderly_prototype_app/core/services/location_service.dart';
import '../data/models/healthcare_facility_model.dart';
import '../data/services/healthcare_favorites_service.dart';
import '../data/services/healthcare_repository.dart';

class HealthcareState {
  final bool isLoading;
  final String? errorMessage;
  final List<HealthcareFacilityWithDistance> facilities;
  final HealthcareCategory? selectedCategory; // null = All
  final String searchQuery;
  final DateTime? lastUpdated;

  const HealthcareState({
    this.isLoading = false,
    this.errorMessage,
    this.facilities = const [],
    this.selectedCategory,
    this.searchQuery = '',
    this.lastUpdated,
  });

  HealthcareState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<HealthcareFacilityWithDistance>? facilities,
    HealthcareCategory? selectedCategory,
    bool clearCategory = false,
    String? searchQuery,
    DateTime? lastUpdated,
    bool clearError = false,
  }) {
    return HealthcareState(
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

class HealthcareNotifier extends StateNotifier<HealthcareState> {
  HealthcareNotifier() : super(const HealthcareState());

  static const int _maxResultsToShow = 20;

  final HealthcareRepository _repository = HealthcareRepository();
  final LocationService _locationService = LocationService();
  final HealthcareFavoritesService _favoritesService =
      HealthcareFavoritesService();

  Set<String> _favoriteIds = {};

  Future<void> loadNearby({bool forceRefresh = false}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      _favoriteIds = await _favoritesService.getFavoriteIds();
      final position = await _locationService.getCurrentPosition();

      var general = <HealthcareFacilityModel>[];
      var pharmacies = <HealthcareFacilityModel>[];

      // Each category fetch is isolated: if pharmacies fail to load, we
      // still show hospitals/health centers, and vice versa.
      try {
        general = await _repository.getFacilities(forceRefresh: forceRefresh);
      } catch (_) {}
      try {
        pharmacies =
            await _repository.getOnDutyPharmacies(forceRefresh: forceRefresh);
      } catch (_) {}

      final combined = [...general, ...pharmacies];
      if (combined.isEmpty) {
        throw HealthcareDataUnavailableException();
      }

      final withDistance = combined.map((facility) {
        final distance = _locationService.distanceInMeters(
          startLatitude: position.latitude,
          startLongitude: position.longitude,
          endLatitude: facility.latitude,
          endLongitude: facility.longitude,
        );
        return HealthcareFacilityWithDistance(
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
    } on HealthcareDataUnavailableException {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AppStrings.healthcareDataUnavailableMessage,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AppStrings.healthcareGenericError,
      );
    }
  }

  void setCategory(HealthcareCategory? category) {
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
    // Force a rebuild — favorites live outside `state` but affect sorting.
    state = state.copyWith();
  }

  /// Facilities filtered by category + search, favorites-first, capped to
  /// a manageable number so the list never overwhelms the user.
  List<HealthcareFacilityWithDistance> get visibleFacilities {
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

final healthcareProvider =
    StateNotifierProvider<HealthcareNotifier, HealthcareState>((ref) {
  return HealthcareNotifier();
});
