import 'package:flutter/material.dart';
import '../models/business_instruction.dart';
import '../models/business_task.dart';
import '../services/ollama_service.dart';

enum ProcessingStep { speech, aiExtraction, preparingTask }

class AiProvider extends ChangeNotifier {
  bool _isProcessing = false;
  ProcessingStep _currentStep = ProcessingStep.speech;
  BusinessInstruction? _extractedInstruction;
  BusinessTask? _extractedTask;
  String? _errorMessage;
  bool _isLowConfidence = false;

  bool get isProcessing => _isProcessing;
  ProcessingStep get currentStep => _currentStep;
  BusinessInstruction? get extractedInstruction => _extractedInstruction;
  BusinessTask? get extractedTask => _extractedTask;
  String? get errorMessage => _errorMessage;
  bool get isLowConfidence => _isLowConfidence;

  void reset() {
    _isProcessing = false;
    _currentStep = ProcessingStep.speech;
    _extractedInstruction = null;
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
    if (speechText.trim().isEmpty) {
      _errorMessage = 'Speech input is empty. Please try recording again.';
      notifyListeners();
      return false;
    }

    _isProcessing = true;
    _errorMessage = null;
    _currentStep = ProcessingStep.speech;
    notifyListeners();

    final ollamaService = OllamaService(baseUrl: ollamaUrl, modelName: gemmaModel);

    // Step 1: Voice Recognition Validation
    await Future.delayed(const Duration(milliseconds: 300));
    _currentStep = ProcessingStep.aiExtraction;
    notifyListeners();

    try {
      // Step 2: Send to Ollama Local Gemma 3 1B AI
      final instruction = await ollamaService.processBusinessInstruction(
        speechText: speechText,
        currentLanguage: languageCode,
      );

      _currentStep = ProcessingStep.preparingTask;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 200));

      // Convert BusinessInstruction to BusinessTask
      final task = instruction.toBusinessTask(currentLang: languageCode);

      _extractedInstruction = instruction;
      _extractedTask = task;
      _isLowConfidence = (instruction.confidence) < 0.60;
      _isProcessing = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('AI Processing error: $e');
      _errorMessage = 'Unable to connect to the local AI model ($gemmaModel). Make sure Ollama is running on your computer ($ollamaUrl).';
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
