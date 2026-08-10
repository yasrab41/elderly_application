import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elderly_prototype_app/core/constants.dart';
import 'package:elderly_prototype_app/core/services/location_service.dart';
import '../data/models/social_models.dart';
import '../data/services/discovery_repository.dart';
import '../data/services/friend_repository.dart';

class DiscoveryState {
  final bool isLoading;
  final String? errorMessage;
  final List<PublicProfileWithDistance> people;
  final Set<String> sentRequestUids;

  const DiscoveryState({
    this.isLoading = false,
    this.errorMessage,
    this.people = const [],
    this.sentRequestUids = const {},
  });

  DiscoveryState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<PublicProfileWithDistance>? people,
    Set<String>? sentRequestUids,
    bool clearError = false,
  }) {
    return DiscoveryState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      people: people ?? this.people,
      sentRequestUids: sentRequestUids ?? this.sentRequestUids,
    );
  }
}

class DiscoveryNotifier extends StateNotifier<DiscoveryState> {
  DiscoveryNotifier() : super(const DiscoveryState());

  final DiscoveryRepository _discoveryRepository = DiscoveryRepository();
  final FriendRepository _friendRepository = FriendRepository();
  final LocationService _locationService = LocationService();

  Future<void> loadNearbyPeople({required Set<String> excludedUids}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // Kick off everything that doesn't depend on anything else at once,
      // instead of awaiting each one in turn — this alone cuts the wait
      // roughly in half versus doing them sequentially.
      final positionFuture = _locationService.getCurrentPosition();
      final profilesFuture = _discoveryRepository.getDiscoverableProfiles();
      final blockedFuture = _friendRepository.getBlockedUids();
      final blockedByFuture = _friendRepository.getBlockedByUids();
      final pendingOutgoingFuture = _friendRepository.getOutgoingPendingUids();

      final position = await positionFuture;
      final allProfiles = await profilesFuture;
      final blockedUids = await blockedFuture;
      final blockedByUids = await blockedByFuture;
      final pendingOutgoing = await pendingOutgoingFuture;

      final filtered = allProfiles.where((p) {
        return !excludedUids.contains(p.uid) &&
            !blockedUids.contains(p.uid) &&
            !blockedByUids.contains(p.uid) &&
            !pendingOutgoing.contains(p.uid);
      }).toList();

      final withDistance = filtered.map((p) {
        double? distance;
        if (p.approxLatitude != null && p.approxLongitude != null) {
          distance = _locationService.distanceInMeters(
            startLatitude: position.latitude,
            startLongitude: position.longitude,
            endLatitude: p.approxLatitude!,
            endLongitude: p.approxLongitude!,
          );
        }
        return PublicProfileWithDistance(profile: p, distanceMeters: distance);
      }).toList()
        ..sort((a, b) {
          if (a.distanceMeters == null && b.distanceMeters == null) return 0;
          if (a.distanceMeters == null) return 1;
          if (b.distanceMeters == null) return -1;
          return a.distanceMeters!.compareTo(b.distanceMeters!);
        });

      state = state.copyWith(
        isLoading: false,
        people: withDistance,
        sentRequestUids: pendingOutgoing,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AppStrings.friendNetworkGenericError,
      );
    }
  }

  Future<void> sendRequest(PublicProfileModel person) async {
    await _friendRepository.sendFriendRequest(person.uid);
    state = state.copyWith(
      sentRequestUids: {...state.sentRequestUids, person.uid},
    );
  }

  Future<void> blockUser(String uid) async {
    await _friendRepository.blockUser(uid);
    state = state.copyWith(
      people: state.people.where((p) => p.profile.uid != uid).toList(),
    );
  }

  Future<void> reportUser(String uid, String reason) async {
    await _friendRepository.reportUser(uid, reason);
  }
}

final discoveryProvider =
    StateNotifierProvider<DiscoveryNotifier, DiscoveryState>((ref) {
  return DiscoveryNotifier();
});
