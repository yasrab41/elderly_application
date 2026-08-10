import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AvatarService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  Future<int> getAvatarId() async {
    final doc = await _firestore.collection('users').doc(_uid).get();
    return (doc.data()?['avatarId'] as num?)?.toInt() ?? 0;
  }

  /// Updates the single shared avatar field on users/{uid}. If this user
  /// currently has a public Friend Network profile (i.e. discoverable is
  /// on), also patches its avatarId so the change shows up there too —
  /// this keeps the avatar in sync no matter which screen it was changed
  /// from, without either screen needing to know about the other.
  Future<void> setAvatarId(int avatarId) async {
    await _firestore
        .collection('users')
        .doc(_uid)
        .set({'avatarId': avatarId}, SetOptions(merge: true));

    final publicDoc = _firestore.collection('publicProfiles').doc(_uid);
    final publicSnapshot = await publicDoc.get();
    if (publicSnapshot.exists) {
      await publicDoc.set({'avatarId': avatarId}, SetOptions(merge: true));
    }
  }
}
