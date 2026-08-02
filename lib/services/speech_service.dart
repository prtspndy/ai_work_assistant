import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;
  Function(String status)? _statusListener;

  bool get isInitialized => _isInitialized;
  bool get isListening => _speechToText.isListening;

  /// Initialize Speech Recognizer
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    try {
      _isInitialized = await _speechToText.initialize(
        onError: (error) => debugPrint('SpeechToText Error: $error'),
        onStatus: (status) {
          debugPrint('SpeechToText Status: $status');
          if (_statusListener != null) {
            _statusListener!(status);
          }
        },
      );
      return _isInitialized;
    } catch (e) {
      debugPrint('SpeechToText init exception: $e');
      return false;
    }
  }

  /// Request microphone permission
  Future<bool> requestMicPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Get appropriate locale string for speech recognition
  String _getLocaleForLang(String appLangCode) {
    switch (appLangCode) {
      case 'gu':
        return 'gu_IN';
      case 'hi':
        return 'hi_IN';
      case 'en':
      default:
        return 'en_IN';
    }
  }

  /// Start listening for voice input
  Future<void> startListening({
    required String languageCode,
    required Function(String text) onResult,
    required Function(double soundLevel) onSoundLevelChanged,
    Function(String status)? onStatus,
  }) async {
    _statusListener = onStatus;

    final hasMic = await requestMicPermission();
    if (!hasMic) {
      throw Exception('Microphone permission denied');
    }

    final initialized = await initialize();
    if (!initialized) {
      throw Exception('Speech recognition not available on this device');
    }

    final targetLocale = _getLocaleForLang(languageCode);

    await _speechToText.listen(
      onResult: (SpeechRecognitionResult result) {
        onResult(result.recognizedWords);
      },
      onSoundLevelChange: onSoundLevelChanged,
      listenOptions: SpeechListenOptions(
        localeId: targetLocale,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 4),
        partialResults: true,
        cancelOnError: false,
        listenMode: ListenMode.dictation,
      ),
    );
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
  }

  /// Cancel listening
  Future<void> cancelListening() async {
    if (_speechToText.isListening) {
      await _speechToText.cancel();
    }
  }
}
