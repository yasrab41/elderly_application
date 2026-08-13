import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elderly_prototype_app/core/constants.dart';
import 'package:elderly_prototype_app/core/models/avatar_options.dart';
import 'package:elderly_prototype_app/core/providers/avatar_provider.dart';
import '../data/models/friend_profile_model.dart';
import '../data/models/social_models.dart';
import '../data/services/distance_bucket.dart';
import '../providers/discovery_provider.dart';
import '../providers/friend_profile_provider.dart';
import '../providers/friends_provider.dart';
import '../providers/notifications_provider.dart';
import '../widgets/friend_person_card.dart';
import '../widgets/safety_actions_sheet.dart';
import 'conversation_screen.dart';
import 'edit_friend_profile_screen.dart';

class FriendNetworkHubScreen extends ConsumerStatefulWidget {
  const FriendNetworkHubScreen({super.key});

  @override
  ConsumerState<FriendNetworkHubScreen> createState() =>
      _FriendNetworkHubScreenState();
}

class _FriendNetworkHubScreenState
    extends ConsumerState<FriendNetworkHubScreen> {
  // Starts true (no async needed to set it) so build()'s very first pass
  // already shows the loading spinner — this is what actually solves the
  // "flash of stale content" problem, safely, without needing to mutate
  // any Riverpod provider state before the widget tree has finished its
  // first build (which is what caused the rebuild-loop regression).
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    // Deferred via addPostFrameCallback deliberately: mutating provider
    // state synchronously during initState — before the first frame has
    // been built — can trigger cascading rebuild-during-build errors with
    // Riverpod. Waiting until after the first frame is the safe pattern.
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadEverything());
  }

  Future<void> _loadEverything() async {
    if (mounted && _isInitialLoad) {
      setState(() => _isInitialLoad = false);
    }

    // Fire these concurrently rather than awaiting one at a time — this
    // alone cuts the total wait roughly in half or more.
    final avatarFuture = ref.read(avatarProvider.notifier).loadIfNeeded();
    final profileFuture =
        ref.read(friendProfileProvider.notifier).loadMyProfile();
    final friendsFuture = ref.read(friendsProvider.notifier).loadAll();

    try {
      await Future.wait([avatarFuture, profileFuture, friendsFuture]);
    } catch (e) {
      // Each individual loader already catches its own errors and settles
      // into a safe state; this outer catch exists purely so an unexpected
      // failure in any one of them can never leave this function - or the
      // screen - stuck. Nothing further to do here.
      debugPrint('[FriendNetworkHubScreen] _loadEverything FAILED: $e');
      return;
    }

    final myProfile = ref.read(friendProfileProvider).profile;
    if (myProfile.discoverable) {
      // Reuse the friends/requests data we just loaded instead of having
      // Discovery redundantly re-fetch and re-resolve all of it again.
      final friendsState = ref.read(friendsProvider);
      final excludedUids = {
        ...friendsState.friends.map((f) => f.friendUid),
        ...friendsState.incomingRequests.map((r) => r.fromUid),
      };
      await ref
          .read(discoveryProvider.notifier)
          .loadNearbyPeople(excludedUids: excludedUids);
    }
  }

  Future<void> _openEditProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditFriendProfileScreen()),
    );
    if (mounted) _loadEverything();
  }

  @override
  Widget build(BuildContext context) {
    // React to the same live counts the Home screen badge uses: whenever a
    // new friend request or message arrives while this screen is already
    // open, re-fetch so the Friend Requests list / unread dots update on
    // their own, instead of only refreshing on manual pull-to-refresh.
    // ref.listen is for side effects (not rebuilding UI directly), which is
    // exactly what we want here - it's safe to call on every build, and it
    // won't loop: these count streams only change when the underlying
    // Firestore documents change, not when we merely re-fetch other data.
    ref.listen<AsyncValue<int>>(pendingRequestsCountProvider, (_, __) {
      if (!_isInitialLoad) _loadEverything();
    });
    ref.listen<AsyncValue<int>>(unreadConversationsCountProvider, (_, __) {
      if (!_isInitialLoad) _loadEverything();
    });

    final profileState = ref.watch(friendProfileProvider);
    final friendsState = ref.watch(friendsProvider);
    final discoveryState = ref.watch(discoveryProvider);

    final isLoading =
        _isInitialLoad || profileState.isLoading || friendsState.isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.friendNetworkTitle)),
      body: RefreshIndicator(
        onRefresh: _loadEverything,
        child: isLoading
            ? ListView(children: const [
                SizedBox(height: 120),
                Center(child: CircularProgressIndicator()),
              ])
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    AppStrings.friendNetworkHubSubtitle,
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  profileState.profile.hasBeenSetUp
                      ? _buildProfileSummaryCard(
                          profileState.profile, ref.watch(avatarProvider))
                      : _buildSetupPromptCard(ref.watch(avatarProvider)),
                  const SizedBox(height: 26),
                  if (friendsState.incomingRequests.isNotEmpty) ...[
                    _sectionHeader(AppStrings.friendRequestsTitle),
                    const SizedBox(height: 10),
                    for (final request in friendsState.incomingRequests)
                      FriendPersonCard(
                        avatarId: request.fromAvatarId,
                        name: request.fromName,
                        actions: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => ref
                                  .read(friendsProvider.notifier)
                                  .rejectRequest(request.id),
                              child: Text(AppStrings.declineButton),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => ref
                                  .read(friendsProvider.notifier)
                                  .acceptRequest(request),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF43A047),
                                foregroundColor: Colors.white,
                              ),
                              child: Text(AppStrings.acceptButton),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 22),
                  ],
                  _sectionHeader(AppStrings.myFriendsTitle),
                  const SizedBox(height: 10),
                  friendsState.friends.isEmpty
                      ? _emptyText(AppStrings.noFriendsYetMessage)
                      : Column(
                          children: friendsState.friends
                              .map((f) => _buildFriendCard(f))
                              .toList(),
                        ),
                  const SizedBox(height: 26),
                  _sectionHeader(AppStrings.nearbyPeopleTitle),
                  const SizedBox(height: 10),
                  _buildNearbySection(profileState, discoveryState),
                ],
              ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Color(0xFF48352A),
          letterSpacing: 0.5),
    );
  }

  Widget _emptyText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(text,
          style: const TextStyle(fontSize: 15, color: Colors.black45)),
    );
  }

  Widget _buildSetupPromptCard(int avatarId) {
    final avatar = avatarOptions[avatarId];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF48352A).withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration:
                BoxDecoration(color: avatar.color, shape: BoxShape.circle),
            child: Icon(avatar.icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 14),
          Text(AppStrings.setupProfilePrompt,
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _openEditProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF48352A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(AppStrings.setupProfileButton,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSummaryCard(FriendProfileModel profile, int avatarId) {
    final avatar = avatarOptions[avatarId];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration:
                    BoxDecoration(color: avatar.color, shape: BoxShape.circle),
                child: Icon(avatar.icon, color: Colors.white, size: 34),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (profile.ageRange != null)
                      Text(
                        profile.ageRange!.label,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87),
                      ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: profile.discoverable
                            ? const Color(0xFFE8F5E9)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            profile.discoverable
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            size: 14,
                            color: profile.discoverable
                                ? const Color(0xFF2E7D32)
                                : Colors.black45,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              profile.discoverable
                                  ? AppStrings.discoverableStatusOn
                                  : AppStrings.discoverableStatusOff,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: profile.discoverable
                                    ? const Color(0xFF2E7D32)
                                    : Colors.black45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _openEditProfile,
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF48352A).withOpacity(0.08),
                ),
                icon: const Icon(Icons.edit_rounded,
                    color: Color(0xFF48352A), size: 20),
                tooltip: AppStrings.editProfileFriendNetworkButton,
              ),
            ],
          ),
          if (profile.bio.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              profile.bio,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ],
          if (profile.interests.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: profile.interests
                  .map((interest) => Chip(
                        label: Text(interest,
                            style: const TextStyle(fontSize: 12)),
                        backgroundColor: const Color(0xFFF3E5F5),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _openEditProfile,
              icon: const Icon(Icons.edit_rounded, size: 18),
              label: Text(AppStrings.editProfileFriendNetworkButton),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF48352A),
                side: const BorderSide(color: Color(0xFF48352A)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendCard(FriendshipModel friend) {
    final hasPreview = friend.lastMessageText != null;
    final subtitle = hasPreview
        ? friend.lastMessageText
        : (friend.since != null
            ? '${AppStrings.sinceFriendsLabel} ${friend.since!.day}/${friend.since!.month}/${friend.since!.year}'
            : null);

    return FriendPersonCard(
      avatarId: friend.friendAvatarId,
      name: friend.friendName,
      isTrusted: friend.isTrustedContact,
      isUnread: friend.isUnreadMessage,
      subtitle: subtitle,
      onMoreOptions: () => showPersonOptionsSheet(
        context,
        isTrusted: friend.isTrustedContact,
        onToggleTrusted: () => ref
            .read(friendsProvider.notifier)
            .toggleTrusted(friend.pairId, !friend.isTrustedContact),
        onRemove: () async {
          final confirmed = await confirmActionDialog(
              context, AppStrings.confirmRemoveFriendMessage);
          if (confirmed) {
            ref.read(friendsProvider.notifier).removeFriend(friend.pairId);
          }
        },
        onBlock: () async {
          final confirmed = await confirmActionDialog(
              context, AppStrings.confirmBlockUserMessage);
          if (confirmed) {
            ref.read(friendsProvider.notifier).blockUser(friend.friendUid);
          }
        },
        onReport: () => showReportReasonSheet(context, (reason) {
          ref
              .read(friendsProvider.notifier)
              .reportUser(friend.friendUid, reason);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppStrings.reportSubmittedMessage)),
          );
        }),
      ),
      actions: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ConversationScreen(
                  friendUid: friend.friendUid,
                  friendName: friend.friendName,
                  friendAvatarId: friend.friendAvatarId,
                ),
              ),
            ).then((_) => ref.read(friendsProvider.notifier).loadAll()),
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
            label: Text(AppStrings.messageButton),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF48352A),
              side: const BorderSide(color: Color(0xFF48352A)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNearbySection(
      FriendProfileState profileState, DiscoveryState discoveryState) {
    if (!profileState.profile.discoverable) {
      return _emptyText(AppStrings.discoverabilityOffNotice);
    }
    if (discoveryState.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (discoveryState.people.isEmpty) {
      return _emptyText(AppStrings.noNearbyPeopleMessage);
    }
    return Column(
      children: discoveryState.people.map((item) {
        final person = item.profile;
        final alreadySent = discoveryState.sentRequestUids.contains(person.uid);
        return FriendPersonCard(
          avatarId: person.avatarId,
          name: person.name,
          subtitle: person.bio,
          tags: person.interests,
          trailingLabel: distanceBucketLabel(item.distanceMeters),
          onMoreOptions: () => showPersonOptionsSheet(
            context,
            onBlock: () async {
              final confirmed = await confirmActionDialog(
                  context, AppStrings.confirmBlockUserMessage);
              if (confirmed) {
                ref.read(discoveryProvider.notifier).blockUser(person.uid);
              }
            },
            onReport: () => showReportReasonSheet(context, (reason) {
              ref
                  .read(discoveryProvider.notifier)
                  .reportUser(person.uid, reason);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppStrings.reportSubmittedMessage)),
              );
            }),
          ),
          actions: [
            Expanded(
              child: ElevatedButton(
                onPressed: alreadySent
                    ? null
                    : () async {
                        await ref
                            .read(discoveryProvider.notifier)
                            .sendRequest(person);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text(AppStrings.friendRequestSentMessage)),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8E24AA),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: Text(alreadySent
                    ? AppStrings.requestedButton
                    : AppStrings.addButton),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
