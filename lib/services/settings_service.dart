import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class SettingsService {
  Future<String> getOllamaUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConfig.prefKeyOllamaUrl) ?? AppConfig.defaultOllamaUrlEmulator;
  }

  Future<bool> setOllamaUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(AppConfig.prefKeyOllamaUrl, url.trim());
  }

  Future<String> getGemmaModel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConfig.prefKeyGemmaModel) ?? AppConfig.defaultGemmaModel;
  }

  Future<bool> setGemmaModel(String modelName) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(AppConfig.prefKeyGemmaModel, modelName.trim());
  }
}
