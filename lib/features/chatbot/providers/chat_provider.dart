import 'package:flutter/material.dart';
import '../data/models/chat_message.dart';
import '../data/services/gemini_service.dart';
import '../data/services/chat_db_service.dart';

class ChatProvider extends ChangeNotifier {
  final GeminiService _apiService = GeminiService();
  final ChatDatabaseService _dbService = ChatDatabaseService();
  final String currentUserId;

  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  ChatProvider({required this.currentUserId}) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    _messages = await _dbService.getMessages(currentUserId);
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      userId: currentUserId,
      message: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    _messages.add(userMsg);
    _isLoading = true;
    notifyListeners();
    await _dbService.insertMessage(userMsg);

    // Prepare context history for Gemini (last 5 messages)
    List<Map<String, String>> context = _messages.reversed
        .take(5)
        .map((m) => {"role": m.isUser ? "user" : "model", "text": m.message})
        .toList()
        .reversed
        .toList();

    final botResponse = await _apiService.getChatResponse(text, context);

    final botMsg = ChatMessage(
      userId: currentUserId,
      message: botResponse,
      isUser: false,
      timestamp: DateTime.now(),
    );

    _messages.add(botMsg);
    await _dbService.insertMessage(botMsg);
    _isLoading = false;
    notifyListeners();
  }
}
