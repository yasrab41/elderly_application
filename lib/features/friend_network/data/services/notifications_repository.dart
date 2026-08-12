import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class NotificationsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  Stream<int> pendingRequestsCountStream() {
    final uid = _uid;
    if (uid == null) return Stream.value(0);
    return _firestore
        .collection('friendRequests')
        .where('toUid', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) => snap.docs.length)
        .handleError((e) {
      debugPrint(
          '[NotificationsRepository] pendingRequestsCountStream error: $e');
      return 0;
    });
  }

  Stream<int> unreadConversationsCountStream() {
    final uid = _uid;
    if (uid == null) return Stream.value(0);
    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: uid)
        .where('unreadFor', isEqualTo: uid)
        .snapshots()
        .map((snap) => snap.docs.length)
        .handleError((e) {
      debugPrint(
          '[NotificationsRepository] unreadConversationsCountStream error: $e');
      return 0;
    });
  }
}
