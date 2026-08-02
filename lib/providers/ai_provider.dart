import 'package:flutter/material.dart';
import '../models/business_task.dart';
import '../services/ollama_service.dart';

enum ProcessingStep { speech, aiExtraction, preparingTask }

class AiProvider extends ChangeNotifier {
  bool _isProcessing = false;
  ProcessingStep _currentStep = ProcessingStep.speech;
  BusinessTask? _extractedTask;
  String? _errorMessage;
  bool _isLowConfidence = false;

  bool get isProcessing => _isProcessing;
  ProcessingStep get currentStep => _currentStep;
  BusinessTask? get extractedTask => _extractedTask;
  String? get errorMessage => _errorMessage;
  bool get isLowConfidence => _isLowConfidence;

  void reset() {
    _isProcessing = false;
    _currentStep = ProcessingStep.speech;
    _extractedTask = null;
    _errorMessage = null;
    _isLowConfidence = false;
    notifyListeners();
  }

  Future<bool> processSpeechToTask({
    required String speechText,
    required String languageCode,
    required String ollamaUrl,
    required String gemmaModel,
  }) async {
    _isProcessing = true;
    _errorMessage = null;
    _currentStep = ProcessingStep.speech;
    notifyListeners();

    final ollamaService = OllamaService(baseUrl: ollamaUrl, modelName: gemmaModel);

    // Step 1: Voice Recognition validation
    await Future.delayed(const Duration(milliseconds: 400));
    _currentStep = ProcessingStep.aiExtraction;
    notifyListeners();

    try {
      // Step 2: Send to Ollama Local Gemma AI
      final jsonMap = await ollamaService.processBusinessInstruction(
        speechText: speechText,
        currentLanguage: languageCode,
      );

      _currentStep = ProcessingStep.preparingTask;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 300));

      // Parse BusinessTask safely
      final task = BusinessTask.fromJson(
        jsonMap,
        rawSpeech: speechText,
        currentLang: languageCode,
      );

      _isLowConfidence = (task.confidence ?? 1.0) < 0.60;
      _extractedTask = task;
      _isProcessing = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('AI Processing error: $e');
      _errorMessage = 'Could not reach Gemma model on Ollama. Make sure Ollama is running on your PC ($ollamaUrl) and model $gemmaModel is pulled.';
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  Future<String> regenerateTaskMessage({
    required BusinessTask task,
    required String languageCode,
    required String ollamaUrl,
    required String gemmaModel,
  }) async {
    final ollamaService = OllamaService(baseUrl: ollamaUrl, modelName: gemmaModel);
    final newMsg = await ollamaService.regenerateMessage(
      originalInstruction: task.originalInstruction,
      customerName: task.customerName ?? '',
      amount: task.amount,
      action: task.action,
      targetLanguage: languageCode,
    );

    if (_extractedTask != null) {
      _extractedTask = _extractedTask!.copyWith(generatedMessage: newMsg);
      notifyListeners();
    }
    return newMsg;
  }

  void updateExtractedTask(BusinessTask updated) {
    _extractedTask = updated;
    notifyListeners();
  }
}
