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

  Future<void> loadNearbyPeople() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final position = await _locationService.getCurrentPosition();
      final allProfiles = await _discoveryRepository.getDiscoverableProfiles();

      final friends = await _friendRepository.getFriends();
      final friendUids = friends.map((f) => f.friendUid).toSet();
      final blockedUids = await _friendRepository.getBlockedUids();
      final blockedByUids = await _friendRepository.getBlockedByUids();
      final pendingOutgoing = await _friendRepository.getOutgoingPendingUids();
      final incoming = await _friendRepository.getIncomingRequests();
      final pendingIncoming = incoming.map((r) => r.fromUid).toSet();

      final filtered = allProfiles.where((p) {
        return !friendUids.contains(p.uid) &&
            !blockedUids.contains(p.uid) &&
            !blockedByUids.contains(p.uid) &&
            !pendingOutgoing.contains(p.uid) &&
            !pendingIncoming.contains(p.uid);
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
