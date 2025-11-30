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
    String language = 'English',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'claim': claim,
          'image_requested': imageRequested,
          'language': language,
        }),
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

  Stream<Map<String, dynamic>> chat(
    String message, {
    String sessionId = 'default_session',
    String language = 'English',
    String agentName = 'TruthGuard',
  }) async* {
    final client = http.Client();
    try {
      final request = http.Request('POST', Uri.parse('$baseUrl/chat'));
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        'message': message,
        'session_id': sessionId,
        'language': language,
        'agent_name': agentName,
      });

      final response = await client.send(request);

      if (response.statusCode == 200) {
        final stream = response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter());

        await for (final line in stream) {
          if (line.trim().isNotEmpty) {
            try {
              yield jsonDecode(line);
            } catch (e) {
              print('Error parsing JSON line: $e');
            }
          }
        }
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    } finally {
      client.close();
    }
  }
}
