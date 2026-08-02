import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class LanguageService {
  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConfig.prefKeyLanguage) ?? 'gu'; // Default to Gujarati
  }

  Future<bool> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(AppConfig.prefKeyLanguage, languageCode);
  }

  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConfig.prefKeyFirstRun) ?? true;
  }

  Future<void> setFirstLaunchCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConfig.prefKeyFirstRun, false);
  }
}
