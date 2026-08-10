import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elderly_prototype_app/core/constants.dart';
import 'package:elderly_prototype_app/core/services/location_service.dart';
import '../data/models/friend_profile_model.dart';
import '../data/services/friend_profile_repository.dart';

class FriendProfileState {
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final FriendProfileModel profile;

  const FriendProfileState({
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.profile = const FriendProfileModel(),
  });

  FriendProfileState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    FriendProfileModel? profile,
    bool clearError = false,
  }) {
    return FriendProfileState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      profile: profile ?? this.profile,
    );
  }
}

class FriendProfileNotifier extends StateNotifier<FriendProfileState> {
  FriendProfileNotifier() : super(const FriendProfileState());

  final FriendProfileRepository _repository = FriendProfileRepository();
  final LocationService _locationService = LocationService();

  Future<void> loadMyProfile() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final profile = await _repository.getMyProfile();
      state = state.copyWith(isLoading: false, profile: profile);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AppStrings.profileSaveErrorMessage,
      );
    }
  }

  /// Saves the given profile. If discoverable is being turned on, first
  /// fetches a coarse location — rounded to ~1km — so it's never precise
  /// enough to pinpoint an address.
  Future<bool> saveProfile(FriendProfileModel draft,
      {required int avatarId}) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      var toSave = draft;
      if (draft.discoverable) {
        try {
          final position = await _locationService.getCurrentPosition();
          toSave = draft.copyWith(
            approxLatitude: _coarsen(position.latitude),
            approxLongitude: _coarsen(position.longitude),
          );
        } catch (_) {
          // Could not get location — save everything else, just without
          // location. Discovery simply won't include this profile yet.
          toSave = draft.copyWith(discoverable: false);
        }
      }

      await _repository.saveMyProfile(toSave, avatarId: avatarId);
      state = state.copyWith(isSaving: false, profile: toSave);
      return true;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: AppStrings.profileSaveErrorMessage,
      );
      return false;
    }
  }

  /// Rounds to ~2 decimal places (~1.1km grid) — enough for "nearby"
  /// discovery, not enough to reveal an exact address.
  double _coarsen(double value) => double.parse(value.toStringAsFixed(2));
}

final friendProfileProvider =
    StateNotifierProvider<FriendProfileNotifier, FriendProfileState>((ref) {
  return FriendProfileNotifier();
});
