import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/localization/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../providers/language_provider.dart';
import '../providers/settings_provider.dart';
import 'language_selection_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _urlController;
  late TextEditingController _modelController;

  @override
  void initState() {
    super.initState();
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    _urlController = TextEditingController(text: settingsProvider.ollamaUrl);
    _modelController = TextEditingController(text: settingsProvider.gemmaModel);
  }

  Future<void> _saveSettings() async {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    await settingsProvider.updateOllamaUrl(_urlController.text.trim());
    await settingsProvider.updateGemmaModel(_modelController.text.trim());

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings updated! Testing connection...'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    final langNames = {'gu': 'ગુજરાતી (Gujarati)', 'hi': 'हिंदी (Hindi)', 'en': 'English'};

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: Text(
          loc.translate('settings'),
          style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Language Card Section
              _buildSectionHeader('APPLICATION LANGUAGE'),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: ListTile(
                  leading: const Icon(Icons.language, color: AppTheme.primaryColor),
                  title: Text(
                    langNames[langProvider.languageCode] ?? 'Gujarati',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LanguageSelectionScreen(isFromSettings: true),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),

              // Local AI & Ollama Configuration Section
              _buildSectionHeader('LOCAL AI & OLLAMA CONFIGURATION'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Connection Status Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Connection Status',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: settingsProvider.isConnected
                                ? AppTheme.accentGreen.withOpacity(0.15)
                                : AppTheme.accentRed.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                settingsProvider.isConnected ? Icons.check_circle : Icons.cancel,
                                size: 14,
                                color: settingsProvider.isConnected ? AppTheme.accentGreen : AppTheme.accentRed,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                settingsProvider.isConnected ? 'Connected' : 'Disconnected',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: settingsProvider.isConnected ? AppTheme.accentGreen : AppTheme.accentRed,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Server Address Input
                    Text(
                      loc.translate('ollama_server'),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.dns_outlined),
                        hintText: 'http://10.0.2.2:11434 or http://192.168.x.x:11434',
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '• Emulator: http://10.0.2.2:11434\n• Desktop: http://localhost:11434\n• Physical Phone: http://<PC-LAN-IP>:11434',
                      style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), height: 1.4),
                    ),
                    const SizedBox(height: 16),

                    // Model Name Input
                    Text(
                      loc.translate('gemma_model'),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _modelController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.memory_outlined),
                        hintText: 'e.g. gemma2:2b',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Test Connection & Save Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: settingsProvider.isTestingConnection
                                ? null
                                : () => settingsProvider.testConnection(),
                            icon: settingsProvider.isTestingConnection
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.sync_rounded, size: 18),
                            label: Text(loc.translate('test_connection')),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveSettings,
                            child: const Text('Save'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // App Info Section
              _buildSectionHeader('ABOUT'),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.info_outline, color: AppTheme.primaryColor, size: 36),
                    const SizedBox(height: 8),
                    Text(
                      loc.translate('app_info'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      loc.translate('version'),
                      style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Color(0xFF94A3B8),
        letterSpacing: 1.0,
      ),
    );
  }
}
