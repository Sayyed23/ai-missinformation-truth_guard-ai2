import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiServiceProvider = Provider((ref) => ApiService());

class ApiService {
  // Use 10.0.2.2 for Android emulator, localhost for Web/Windows
  // For now, assuming Web/Windows or physical device on same network
  static const String baseUrl = 'http://127.0.0.1:8002';

  Future<Map<String, dynamic>> verifyClaim(
    String claim, {
    bool imageRequested = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'claim': claim, 'image_requested': imageRequested}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to verify claim: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  Future<Map<String, dynamic>> chat(
    String message, {
    String sessionId = 'default_session',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message, 'session_id': sessionId}),
      );

      if (response.statusCode == 200) {
        // The backend now returns { "response": "...", "assessment": "...", "image_prompt": "..." }
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to send message: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }
}
