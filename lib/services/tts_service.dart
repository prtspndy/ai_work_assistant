import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;

  bool get isSpeaking => _isSpeaking;

  TtsService() {
    _initTts();
  }

  void _initTts() {
    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
    });

    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
    });

    _flutterTts.setErrorHandler((msg) {
      debugPrint('TTS Error: $msg');
      _isSpeaking = false;
    });
  }

  String _getTtsLanguageCode(String appLangCode) {
    switch (appLangCode) {
      case 'gu':
        return 'gu-IN';
      case 'hi':
        return 'hi-IN';
      case 'en':
      default:
        return 'en-IN';
    }
  }

  Future<void> speak(String text, String languageCode) async {
    if (text.trim().isEmpty) return;

    final ttsLang = _getTtsLanguageCode(languageCode);

    try {
      final isAvailable = await _flutterTts.isLanguageAvailable(ttsLang);
      if (isAvailable == true) {
        await _flutterTts.setLanguage(ttsLang);
      } else {
        // Fallback to Hindi or English if Gujarati voice is not installed on device
        debugPrint('TTS language $ttsLang not available. Falling back to hi-IN or en-US.');
        final hiAvailable = await _flutterTts.isLanguageAvailable('hi-IN');
        if (hiAvailable == true) {
          await _flutterTts.setLanguage('hi-IN');
        } else {
          await _flutterTts.setLanguage('en-US');
        }
      }

      await _flutterTts.setSpeechRate(0.45);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _isSpeaking = true;
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('Error speaking text: $e');
      _isSpeaking = false;
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
    } catch (e) {
      debugPrint('Error stopping TTS: $e');
    }
  }
}
