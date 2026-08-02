import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../services/ollama_service.dart';
import '../services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  
  String _ollamaUrl = AppConfig.defaultOllamaUrlLocal;
  String _gemmaModel = AppConfig.defaultGemmaModel;
  bool _isConnected = false;
  bool _isTestingConnection = false;
  String? _connectionError;

  String get ollamaUrl => _ollamaUrl;
  String get gemmaModel => _gemmaModel;
  bool get isConnected => _isConnected;
  bool get isTestingConnection => _isTestingConnection;
  String? get connectionError => _connectionError;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _ollamaUrl = await _settingsService.getOllamaUrl();
    _gemmaModel = await _settingsService.getGemmaModel();
    notifyListeners();
    testConnection();
  }

  Future<void> updateOllamaUrl(String url) async {
    _ollamaUrl = url.trim();
    await _settingsService.setOllamaUrl(_ollamaUrl);
    notifyListeners();
    await testConnection();
  }

  Future<void> updateGemmaModel(String model) async {
    _gemmaModel = model.trim();
    await _settingsService.setGemmaModel(_gemmaModel);
    notifyListeners();
    await testConnection();
  }

  Future<bool> testConnection() async {
    _isTestingConnection = true;
    _connectionError = null;
    notifyListeners();

    final ollamaService = OllamaService(baseUrl: _ollamaUrl, modelName: _gemmaModel);
    final result = await ollamaService.checkConnection();
    
    _isConnected = result;
    _isTestingConnection = false;
    if (!result) {
      _connectionError = 'Unable to connect to local AI at $_ollamaUrl. Ensure Ollama is running and model $_gemmaModel is loaded.';
    }
    notifyListeners();
    return result;
  }
}
