import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/message_model.dart';

class MessagingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  String conversationId(String otherUid) {
    final sorted = [_uid, otherUid]..sort();
    return sorted.join('_');
  }

  Stream<List<MessageModel>> messagesStream(String friendUid) {
    final id = conversationId(friendUid);
    return _firestore
        .collection('conversations')
        .doc(id)
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snap) => snap.docs.map(MessageModel.fromDoc).toList());
  }

  Future<void> sendMessage({
    required String friendUid,
    required String content,
    required MessageType type,
  }) async {
    final id = conversationId(friendUid);
    final conversationRef = _firestore.collection('conversations').doc(id);

    await conversationRef.set({
      'participants': [_uid, friendUid],
      'lastMessageText': content,
      'lastMessageAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await conversationRef.collection('messages').add({
      'senderUid': _uid,
      'type': type == MessageType.template ? 'template' : 'freeText',
      'content': content,
      'sentAt': FieldValue.serverTimestamp(),
    });
  }

  /// Returns {friendUid: {lastMessageText, lastMessageAt}} for the given
  /// friend uids — used to show a message preview on the friends list.
  Future<Map<String, Map<String, dynamic>>> getConversationPreviews(
      List<String> friendUids) async {
    final entries = await Future.wait(friendUids.map((friendUid) async {
      final id = conversationId(friendUid);
      final doc = await _firestore.collection('conversations').doc(id).get();
      return MapEntry(friendUid, doc.data());
    }));

    final result = <String, Map<String, dynamic>>{};
    for (final entry in entries) {
      final data = entry.value;
      if (data != null && data['lastMessageText'] != null) {
        result[entry.key] = data;
      }
    }
    return result;
  }
}
