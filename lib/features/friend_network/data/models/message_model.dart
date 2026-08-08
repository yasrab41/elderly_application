import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { template, freeText }

class MessageModel {
  final String id;
  final String senderUid;
  final MessageType type;
  final String content;
  final DateTime? sentAt;

  const MessageModel({
    required this.id,
    required this.senderUid,
    required this.type,
    required this.content,
    this.sentAt,
  });

  factory MessageModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return MessageModel(
      id: doc.id,
      senderUid: data['senderUid'] as String? ?? '',
      type: (data['type'] as String? ?? 'freeText') == 'template'
          ? MessageType.template
          : MessageType.freeText,
      content: data['content'] as String? ?? '',
      sentAt: (data['sentAt'] as Timestamp?)?.toDate(),
    );
  }
}
