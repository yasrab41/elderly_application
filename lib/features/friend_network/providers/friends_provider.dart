import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elderly_prototype_app/core/constants.dart';
import '../data/models/social_models.dart';
import '../data/services/friend_repository.dart';
import '../data/services/messaging_repository.dart';

class FriendsState {
  final bool isLoading;
  final String? errorMessage;
  final List<FriendRequestModel> incomingRequests;
  final List<FriendshipModel> friends;

  const FriendsState({
    this.isLoading = false,
    this.errorMessage,
    this.incomingRequests = const [],
    this.friends = const [],
  });

  FriendsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<FriendRequestModel>? incomingRequests,
    List<FriendshipModel>? friends,
    bool clearError = false,
  }) {
    return FriendsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      incomingRequests: incomingRequests ?? this.incomingRequests,
      friends: friends ?? this.friends,
    );
  }
}

class FriendsNotifier extends StateNotifier<FriendsState> {
  FriendsNotifier() : super(const FriendsState());

  final FriendRepository _repository = FriendRepository();
  final MessagingRepository _messagingRepository = MessagingRepository();

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final requests = await _repository.getIncomingRequests();
      var friends = await _repository.getFriends();

      final previews = await _messagingRepository
          .getConversationPreviews(friends.map((f) => f.friendUid).toList());
      friends = friends.map((f) {
        final preview = previews[f.friendUid];
        if (preview == null) return f;
        return f.copyWithMessagePreview(
          lastMessageText: preview['lastMessageText'] as String?,
          lastMessageAt: (preview['lastMessageAt'] as Timestamp?)?.toDate(),
          isUnreadMessage: _messagingRepository.isUnreadForMe(preview),
        );
      }).toList();

      state = state.copyWith(
        isLoading: false,
        incomingRequests: requests,
        friends: friends,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AppStrings.friendNetworkGenericError,
      );
    }
  }

  Future<void> acceptRequest(FriendRequestModel request) async {
    await _repository.acceptRequest(request);
    await loadAll();
  }

  Future<void> rejectRequest(String requestId) async {
    await _repository.rejectRequest(requestId);
    await loadAll();
  }

  Future<void> removeFriend(String pairId) async {
    await _repository.removeFriend(pairId);
    await loadAll();
  }

  Future<void> toggleTrusted(String pairId, bool value) async {
    await _repository.setTrustedContact(pairId, value);
    await loadAll();
  }

  Future<void> blockUser(String uid) async {
    await _repository.blockUser(uid);
    await loadAll();
  }

  Future<void> reportUser(String uid, String reason) async {
    await _repository.reportUser(uid, reason);
  }
}

final friendsProvider =
    StateNotifierProvider<FriendsNotifier, FriendsState>((ref) {
  return FriendsNotifier();
});
