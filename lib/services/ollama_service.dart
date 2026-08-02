import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../ai/gemma_prompt_builder.dart';

class OllamaService {
  final String baseUrl;
  final String modelName;
  final Duration timeout;

  OllamaService({
    required this.baseUrl,
    required this.modelName,
    this.timeout = const Duration(seconds: 30),
  });

  String _formatUrl(String endpoint) {
    final cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    return '$cleanBase$endpoint';
  }

  /// Checks if Ollama server is reachable
  Future<bool> checkConnection() async {
    try {
      final url = Uri.parse(_formatUrl('/api/tags'));
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Ollama connection check failed: $e');
      return false;
    }
  }

  /// Sanitizes raw string response from Gemma to extract valid JSON
  String _sanitizeJson(String rawText) {
    var text = rawText.trim();
    // Remove markdown codeblock fences if returned
    if (text.contains('```json')) {
      text = text.split('```json')[1].split('```')[0].trim();
    } else if (text.contains('```')) {
      text = text.split('```')[1].split('```')[0].trim();
    }

    // Locate first '{' and last '}'
    final startIdx = text.indexOf('{');
    final endIdx = text.lastIndexOf('}');
    if (startIdx != -1 && endIdx != -1 && endIdx > startIdx) {
      text = text.substring(startIdx, endIdx + 1);
    }
    return text;
  }

  /// Send prompt to Gemma via Ollama API
  Future<Map<String, dynamic>> processBusinessInstruction({
    required String speechText,
    required String currentLanguage,
    bool isRetry = false,
  }) async {
    final prompt = GemmaPromptBuilder.buildExtractionPrompt(
      userSpeech: speechText,
      currentLanguage: currentLanguage,
    );

    try {
      final url = Uri.parse(_formatUrl('/api/generate'));
      final body = jsonEncode({
        'model': modelName,
        'prompt': prompt,
        'stream': false,
        'options': {
          'temperature': 0.1, // Low temperature for deterministic JSON output
        }
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(timeout);

      if (response.statusCode != 200) {
        throw Exception('Ollama returned status code ${response.statusCode}');
      }

      final responseJson = jsonDecode(response.body);
      final rawResponseText = responseJson['response'] as String? ?? '';
      
      final cleanedText = _sanitizeJson(rawResponseText);
      
      try {
        final parsedMap = jsonDecode(cleanedText) as Map<String, dynamic>;
        return parsedMap;
      } catch (parseError) {
        if (!isRetry) {
          debugPrint('JSON parsing failed. Retrying ONCE with explicit prompt...');
          return await _retryWithFixPrompt(speechText, currentLanguage);
        } else {
          rethrow;
        }
      }
    } catch (e) {
      debugPrint('Ollama API error: $e');
      rethrow;
    }
  }

  /// Retry once if first attempt returned malformed JSON
  Future<Map<String, dynamic>> _retryWithFixPrompt(String speechText, String currentLanguage) async {
    final fixPrompt = '''
Your previous output was not valid JSON. Return ONLY valid raw JSON for the instruction: "$speechText".
Do not output any markdown code blocks, explanation, or conversational text.
''';

    final url = Uri.parse(_formatUrl('/api/generate'));
    final body = jsonEncode({
      'model': modelName,
      'prompt': fixPrompt,
      'stream': false,
      'options': {'temperature': 0.0}
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    ).timeout(timeout);

    final responseJson = jsonDecode(response.body);
    final rawText = responseJson['response'] as String? ?? '';
    final cleanedText = _sanitizeJson(rawText);
    return jsonDecode(cleanedText) as Map<String, dynamic>;
  }

  /// Regenerate message for a business task
  Future<String> regenerateMessage({
    required String originalInstruction,
    required String customerName,
    required double? amount,
    required String? action,
    required String targetLanguage,
  }) async {
    final prompt = GemmaPromptBuilder.buildRegenerationPrompt(
      originalInstruction: originalInstruction,
      customerName: customerName,
      amount: amount,
      action: action,
      targetLanguage: targetLanguage,
    );

    try {
      final url = Uri.parse(_formatUrl('/api/generate'));
      final body = jsonEncode({
        'model': modelName,
        'prompt': prompt,
        'stream': false,
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final resMap = jsonDecode(response.body);
        return (resMap['response'] as String? ?? '').trim();
      }
    } catch (e) {
      debugPrint('Error regenerating message: $e');
    }

    // Default fallback
    return originalInstruction;
  }
}
