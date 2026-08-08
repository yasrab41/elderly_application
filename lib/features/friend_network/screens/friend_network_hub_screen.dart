import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elderly_prototype_app/core/constants.dart';
import '../data/models/friend_profile_model.dart';
import '../data/models/social_models.dart';
import '../data/services/distance_bucket.dart';
import '../providers/discovery_provider.dart';
import '../providers/friend_profile_provider.dart';
import '../providers/friends_provider.dart';
import '../widgets/friend_person_card.dart';
import '../widgets/safety_actions_sheet.dart';
import 'edit_friend_profile_screen.dart';

class FriendNetworkHubScreen extends ConsumerStatefulWidget {
  const FriendNetworkHubScreen({super.key});

  @override
  ConsumerState<FriendNetworkHubScreen> createState() =>
      _FriendNetworkHubScreenState();
}

class _FriendNetworkHubScreenState
    extends ConsumerState<FriendNetworkHubScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadEverything());
  }

  Future<void> _loadEverything() async {
    await ref.read(friendProfileProvider.notifier).loadMyProfile();
    await ref.read(friendsProvider.notifier).loadAll();
    final myProfile = ref.read(friendProfileProvider).profile;
    if (myProfile.discoverable) {
      await ref.read(discoveryProvider.notifier).loadNearbyPeople();
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
    final profileState = ref.watch(friendProfileProvider);
    final friendsState = ref.watch(friendsProvider);
    final discoveryState = ref.watch(discoveryProvider);

    final isLoading = profileState.isLoading || friendsState.isLoading;

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
                      ? _buildProfileSummaryCard(profileState.profile)
                      : _buildSetupPromptCard(),
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

  Widget _buildSetupPromptCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF48352A).withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.person_add_alt_1_rounded,
              size: 36, color: Color(0xFF48352A)),
          const SizedBox(height: 12),
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

  Widget _buildProfileSummaryCard(FriendProfileModel profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              profile.discoverable
                  ? AppStrings.discoverableLabel
                  : AppStrings.setupProfileButton,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: profile.discoverable
                    ? const Color(0xFF43A047)
                    : Colors.black45,
              ),
            ),
          ),
          TextButton(
            onPressed: _openEditProfile,
            child: Text(AppStrings.editProfileFriendNetworkButton),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendCard(FriendshipModel friend) {
    return FriendPersonCard(
      avatarId: friend.friendAvatarId,
      name: friend.friendName,
      isTrusted: friend.isTrustedContact,
      subtitle: friend.since != null
          ? '${AppStrings.sinceFriendsLabel} ${friend.since!.day}/${friend.since!.month}/${friend.since!.year}'
          : null,
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
      actions: const [],
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
