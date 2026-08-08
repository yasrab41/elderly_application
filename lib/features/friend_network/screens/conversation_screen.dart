import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:elderly_prototype_app/core/constants.dart';
import '../data/models/friend_profile_model.dart';
import '../data/models/message_model.dart';
import '../data/services/messaging_repository.dart';

class ConversationScreen extends StatefulWidget {
  final String friendUid;
  final String friendName;
  final int friendAvatarId;

  const ConversationScreen({
    super.key,
    required this.friendUid,
    required this.friendName,
    required this.friendAvatarId,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final MessagingRepository _repository = MessagingRepository();
  final TextEditingController _textController = TextEditingController();
  final String _myUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  bool _isSending = false;

  static const List<String> _templates = [
    AppStrings.templateHello,
    AppStrings.templateHowAreYou,
    AppStrings.templateAreYouAvailable,
    AppStrings.templateLetsWalk,
    AppStrings.templateLetsHaveTea,
    AppStrings.templateThankYou,
    AppStrings.templateSeeYouSoon,
    AppStrings.templateRunningLate,
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _send(String content, MessageType type) async {
    if (content.trim().isEmpty || _isSending) return;
    setState(() => _isSending = true);
    try {
      await _repository.sendMessage(
        friendUid: widget.friendUid,
        content: content.trim(),
        type: type,
      );
      _textController.clear();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.messageSendErrorMessage)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatar = avatarOptions[widget.friendAvatarId];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: avatar.color,
              radius: 18,
              child: Icon(avatar.icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text(widget.friendName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildQuickReplies(),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<List<MessageModel>>(
      stream: _repository.messagesStream(widget.friendUid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final messages = snapshot.data ?? [];
        if (messages.isEmpty) {
          return Center(
            child: Text(
              AppStrings.noMessagesYetMessage,
              style: const TextStyle(fontSize: 16, color: Colors.black45),
            ),
          );
        }
        return ListView.builder(
          reverse: true,
          padding: const EdgeInsets.all(16),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isMine = message.senderUid == _myUid;
            return Align(
              alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75),
                decoration: BoxDecoration(
                  color: isMine
                      ? const Color(0xFF48352A)
                      : const Color(0xFFF3E5F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  message.content,
                  style: TextStyle(
                    fontSize: 16,
                    color: isMine ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuickReplies() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SizedBox(
        height: 44,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          children: _templates
              .map((template) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: OutlinedButton(
                      onPressed: _isSending
                          ? null
                          : () => _send(template, MessageType.template),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF48352A),
                        side: const BorderSide(color: Color(0xFF48352A)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      child:
                          Text(template, style: const TextStyle(fontSize: 14)),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                style: const TextStyle(fontSize: 16),
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: AppStrings.messageInputHint,
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (value) => _send(value, MessageType.freeText),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: const Color(0xFF48352A),
              radius: 24,
              child: IconButton(
                onPressed: _isSending
                    ? null
                    : () => _send(_textController.text, MessageType.freeText),
                icon: const Icon(Icons.send_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
