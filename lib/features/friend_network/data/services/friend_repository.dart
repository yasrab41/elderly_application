import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/social_models.dart';

class FriendRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  List<String> _sortedPair(String a, String b) => [a, b]..sort();
  String _pairId(String a, String b) => _sortedPair(a, b).join('_');

  Future<void> sendFriendRequest(String toUid) async {
    await _firestore.collection('friendRequests').add({
      'fromUid': _uid,
      'toUid': toUid,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<FriendRequestModel>> getIncomingRequests() async {
    final snap = await _firestore
        .collection('friendRequests')
        .where('toUid', isEqualTo: _uid)
        .where('status', isEqualTo: 'pending')
        .get();

    final requests = <FriendRequestModel>[];
    for (final doc in snap.docs) {
      final data = doc.data();
      final fromUid = data['fromUid'] as String;
      final profileDoc =
          await _firestore.collection('publicProfiles').doc(fromUid).get();
      final p = profileDoc.data();
      requests.add(FriendRequestModel(
        id: doc.id,
        fromUid: fromUid,
        toUid: data['toUid'] as String,
        fromName: p?['name'] as String? ?? 'HealthCare+ User',
        fromAvatarId: (p?['avatarId'] as num?)?.toInt() ?? 0,
        status: data['status'] as String,
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      ));
    }
    return requests;
  }

  Future<Set<String>> getOutgoingPendingUids() async {
    final snap = await _firestore
        .collection('friendRequests')
        .where('fromUid', isEqualTo: _uid)
        .where('status', isEqualTo: 'pending')
        .get();
    return snap.docs.map((d) => d.data()['toUid'] as String).toSet();
  }

  Future<void> acceptRequest(FriendRequestModel request) async {
    final sorted = _sortedPair(request.fromUid, request.toUid);
    final pairId = sorted.join('_');
    await _firestore.collection('friendships').doc(pairId).set({
      'uidA': sorted[0],
      'uidB': sorted[1],
      'since': FieldValue.serverTimestamp(),
      'trusted': {sorted[0]: false, sorted[1]: false},
    });
    await _firestore
        .collection('friendRequests')
        .doc(request.id)
        .update({'status': 'accepted'});
  }

  Future<void> rejectRequest(String requestId) async {
    await _firestore
        .collection('friendRequests')
        .doc(requestId)
        .update({'status': 'rejected'});
  }

  Future<List<FriendshipModel>> getFriends() async {
    final resultsA = await _firestore
        .collection('friendships')
        .where('uidA', isEqualTo: _uid)
        .get();
    final resultsB = await _firestore
        .collection('friendships')
        .where('uidB', isEqualTo: _uid)
        .get();

    final friendships = <FriendshipModel>[];
    for (final doc in [...resultsA.docs, ...resultsB.docs]) {
      final data = doc.data();
      final uidA = data['uidA'] as String;
      final uidB = data['uidB'] as String;
      final friendUid = uidA == _uid ? uidB : uidA;
      final profileDoc =
          await _firestore.collection('publicProfiles').doc(friendUid).get();
      final p = profileDoc.data();
      final trusted = (data['trusted'] as Map?)?[_uid] as bool? ?? false;
      friendships.add(FriendshipModel(
        pairId: doc.id,
        friendUid: friendUid,
        friendName: p?['name'] as String? ?? 'HealthCare+ User',
        friendAvatarId: (p?['avatarId'] as num?)?.toInt() ?? 0,
        since: (data['since'] as Timestamp?)?.toDate(),
        isTrustedContact: trusted,
      ));
    }
    return friendships;
  }

  Future<void> removeFriend(String pairId) async {
    await _firestore.collection('friendships').doc(pairId).delete();
  }

  Future<void> setTrustedContact(String pairId, bool value) async {
    await _firestore
        .collection('friendships')
        .doc(pairId)
        .update({'trusted.$_uid': value});
  }

  Future<void> blockUser(String blockedUid) async {
    await _firestore
        .collection('blocks')
        .doc(_uid)
        .collection('blockedUsers')
        .doc(blockedUid)
        .set({'blockedAt': FieldValue.serverTimestamp()});
    // Mirror doc so the blocked user's own client can check "has this
    // person blocked me" without needing read access to my block list.
    await _firestore
        .collection('blockedBy')
        .doc(blockedUid)
        .collection('blockedByUsers')
        .doc(_uid)
        .set({'blockedAt': FieldValue.serverTimestamp()});

    final pairId = _pairId(_uid, blockedUid);
    await _firestore
        .collection('friendships')
        .doc(pairId)
        .delete()
        .catchError((_) {});
  }

  Future<Set<String>> getBlockedUids() async {
    final snap = await _firestore
        .collection('blocks')
        .doc(_uid)
        .collection('blockedUsers')
        .get();
    return snap.docs.map((d) => d.id).toSet();
  }

  Future<Set<String>> getBlockedByUids() async {
    final snap = await _firestore
        .collection('blockedBy')
        .doc(_uid)
        .collection('blockedByUsers')
        .get();
    return snap.docs.map((d) => d.id).toSet();
  }

  Future<void> reportUser(String reportedUid, String reason) async {
    await _firestore.collection('reports').add({
      'reportedUid': reportedUid,
      'reportedByUid': _uid,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'open',
    });
  }
}
