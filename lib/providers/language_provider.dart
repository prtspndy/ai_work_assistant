import 'package:flutter/material.dart';
import '../services/language_service.dart';

class LanguageProvider extends ChangeNotifier {
  final LanguageService _languageService = LanguageService();
  Locale _currentLocale = const Locale('gu'); // Default to Gujarati
  bool _isFirstRun = true;
  bool _isInitialized = false;

  Locale get currentLocale => _currentLocale;
  String get languageCode => _currentLocale.languageCode;
  bool get isFirstRun => _isFirstRun;
  bool get isInitialized => _isInitialized;

  LanguageProvider() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final savedCode = await _languageService.getLanguage();
    _currentLocale = Locale(savedCode);
    _isFirstRun = await _languageService.isFirstLaunch();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    if (_currentLocale.languageCode == code) return;
    _currentLocale = Locale(code);
    await _languageService.setLanguage(code);
    notifyListeners();
  }

  Future<void> completeFirstRun() async {
    _isFirstRun = false;
    await _languageService.setFirstLaunchCompleted();
    notifyListeners();
  }
}
