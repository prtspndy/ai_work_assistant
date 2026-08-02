class AppConfig {
  static const String appName = 'VyaparMitra';
  static const String altAppName = 'Vyapar Vani';
  static const String appVersion = '1.0.0';

  // Configurable URLs
  static const String defaultOllamaUrlEmulator = 'http://10.0.2.2:11434';
  static const String defaultOllamaUrlLocal = 'http://localhost:11434';
  
  // Default Gemma Model Tag
  static const String defaultGemmaModel = 'gemma3:1b';

  // Keys for SharedPreferences
  static const String prefKeyLanguage = 'user_language';
  static const String prefKeyOllamaUrl = 'ollama_base_url';
  static const String prefKeyGemmaModel = 'gemma_model_name';
  static const String prefKeyFirstRun = 'is_first_run';

  // Supported Locales
  static const List<String> supportedLanguages = ['gu', 'hi', 'en'];
}
