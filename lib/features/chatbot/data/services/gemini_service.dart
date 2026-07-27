import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  // Use the model name that worked in your Python test: gemini-1.5-flash or gemini-3-flash
  final String _baseUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent";

  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? "";

  Future<String> getChatResponse(
      String prompt, List<Map<String, String>> history) async {
    if (_apiKey.isEmpty) return "Error: API Key not found in .env file.";

    try {
      final response = await http.post(
        Uri.parse("$_baseUrl?key=$_apiKey"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            ...history.map((m) => {
                  // FIX: Pass the role directly since ChatProvider already
                  // sets it to "user" or "model"
                  "role": m['role'],
                  "parts": [
                    {"text": m['text']}
                  ]
                }),
            {
              "role": "user",
              "parts": [
                {"text": prompt}
              ]
            }
          ],
          "generationConfig": {
            "temperature": 0.7,
            "maxOutputTokens": 800,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        // This will print the exact reason (e.g., "Invalid Role") to your screen
        return "Error: ${response.statusCode}\n${response.body}";
      }
    } catch (e) {
      return "Connection failed. Please check your internet.";
    }
  }
}
