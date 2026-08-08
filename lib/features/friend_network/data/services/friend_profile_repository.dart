import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/friend_profile_model.dart';

class FriendProfileUnavailableException implements Exception {}

class FriendProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw FriendProfileUnavailableException();
    return uid;
  }

  Future<FriendProfileModel> getMyProfile() async {
    final doc = await _firestore.collection('users').doc(_uid).get();
    final data = doc.data();
    return FriendProfileModel.fromMap(
        data?['friendProfile'] as Map<String, dynamic>?);
  }

  /// Saves the profile to the private doc, and mirrors the safe subset to
  /// the public doc only if discoverable is on — otherwise removes the
  /// public doc entirely so nothing is left visible to other users.
  Future<void> saveMyProfile(FriendProfileModel profile) async {
    final uid = _uid;
    final currentUser = _auth.currentUser;
    final name = currentUser?.displayName?.trim();

    await _firestore
        .collection('users')
        .doc(uid)
        .set(profile.toUserDocMap(), SetOptions(merge: true));

    final publicDoc = _firestore.collection('publicProfiles').doc(uid);
    if (profile.discoverable) {
      await publicDoc.set(
        profile.toPublicProfileMap(
          name: (name != null && name.isNotEmpty) ? name : 'HealthCare+ User',
        ),
      );
    } else {
      await publicDoc.delete().catchError((_) {
        // Doc may not exist yet — nothing to clean up, safe to ignore.
      });
    }
  }
}
