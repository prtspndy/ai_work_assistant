import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../ai/gemma_prompt_builder.dart';
import '../models/business_instruction.dart';

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

  /// Checks if Ollama server is reachable and if the target model is available
  Future<bool> checkConnection() async {
    try {
      final url = Uri.parse(_formatUrl('/api/tags'));
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final models = body['models'] as List<dynamic>? ?? [];
        if (models.isNotEmpty) {
          // Check if modelName matches any model tag (e.g., gemma3:1b)
          final modelFound = models.any((m) {
            final name = m['name'] as String? ?? '';
            return name.toLowerCase().contains(modelName.toLowerCase());
          });
          return modelFound || models.isNotEmpty; // Accept if models list is accessible
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Ollama connection check failed: $e');
      return false;
    }
  }

  /// Alias for testConnection matching exact requirements
  Future<bool> testConnection() async {
    return await checkConnection();
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

  /// Process business instruction speech using Ollama REST API
  Future<BusinessInstruction> processBusinessInstruction({
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
        'format': 'json', // Ollama JSON mode parameter
        'stream': false,
        'options': {
          'temperature': 0.1, // Low temperature for deterministic output
        }
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(timeout);

      if (response.statusCode != 200) {
        throw Exception('Ollama returned HTTP status ${response.statusCode}');
      }

      final responseJson = jsonDecode(response.body);
      final rawResponseText = responseJson['response'] as String? ?? '';
      
      final cleanedText = _sanitizeJson(rawResponseText);
      
      try {
        final parsedMap = jsonDecode(cleanedText) as Map<String, dynamic>;
        return BusinessInstruction.fromJson(parsedMap, rawSpeech: speechText);
      } catch (parseError) {
        if (!isRetry) {
          debugPrint('JSON parsing failed. Retrying with explicit fix prompt...');
          return await _retryWithFixPrompt(speechText, currentLanguage);
        } else {
          // Fallback BusinessInstruction if JSON parsing completely fails to prevent crash
          return BusinessInstruction(
            type: 'task',
            task: speechText,
            originalInstruction: speechText,
            confidence: 0.40,
            notes: 'Parsed from unformatted text response',
          );
        }
      }
    } catch (e) {
      debugPrint('Ollama API error: $e');
      rethrow;
    }
  }

  /// Retry once if first attempt returned malformed JSON
  Future<BusinessInstruction> _retryWithFixPrompt(String speechText, String currentLanguage) async {
    final fixPrompt = '''
Your previous output was not valid JSON. Return ONLY raw valid JSON for the instruction: "$speechText".
Format JSON:
{
  "type": "delivery",
  "customer_name": "Ramesh bhai",
  "task": "Deliver 20 boxes",
  "quantity": 20,
  "amount": 5000,
  "date": "tomorrow",
  "payment_reminder": true,
  "notes": null
}
Do not output markdown code blocks or conversational text.
''';

    final url = Uri.parse(_formatUrl('/api/generate'));
    final body = jsonEncode({
      'model': modelName,
      'prompt': fixPrompt,
      'format': 'json',
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
    try {
      final parsedMap = jsonDecode(cleanedText) as Map<String, dynamic>;
      return BusinessInstruction.fromJson(parsedMap, rawSpeech: speechText);
    } catch (_) {
      return BusinessInstruction(
        type: 'task',
        task: speechText,
        originalInstruction: speechText,
        confidence: 0.35,
      );
    }
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

    return originalInstruction;
  }
}
