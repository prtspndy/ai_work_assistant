import 'package:flutter/material.dart';
import '../services/speech_service.dart';

class VoiceProvider extends ChangeNotifier {
  final SpeechService _speechService = SpeechService();

  String _recognizedText = '';
  bool _isListening = false;
  double _soundLevel = 0.0;
  String? _errorMessage;
  Function()? onSpeechComplete;

  String get recognizedText => _recognizedText;
  bool get isListening => _isListening;
  double get soundLevel => _soundLevel;
  String? get errorMessage => _errorMessage;

  void clearTranscript() {
    _recognizedText = '';
    _errorMessage = null;
    _soundLevel = 0.0;
    notifyListeners();
  }

  Future<void> startListening(String languageCode, {Function()? onComplete}) async {
    _recognizedText = '';
    _errorMessage = null;
    _isListening = true;
    onSpeechComplete = onComplete;
    notifyListeners();

    try {
      await _speechService.startListening(
        languageCode: languageCode,
        onResult: (text) {
          _recognizedText = text;
          notifyListeners();
        },
        onSoundLevelChanged: (level) {
          _soundLevel = level;
          notifyListeners();
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (_isListening) {
              _isListening = false;
              notifyListeners();
              if (_recognizedText.trim().isNotEmpty && onSpeechComplete != null) {
                onSpeechComplete!();
              }
            }
          }
        },
      );
    } catch (e) {
      _errorMessage = e.toString();
      _isListening = false;
      notifyListeners();
    }
  }

  Future<void> stopListening() async {
    await _speechService.stopListening();
    _isListening = false;
    notifyListeners();
  }

  Future<void> cancelListening() async {
    await _speechService.cancelListening();
    _isListening = false;
    _recognizedText = '';
    notifyListeners();
  }
}
