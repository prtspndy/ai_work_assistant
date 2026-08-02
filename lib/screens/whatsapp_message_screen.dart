import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../core/localization/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../models/business_task.dart';
import '../providers/ai_provider.dart';
import '../providers/language_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/task_provider.dart';
import '../services/tts_service.dart';
import 'home_screen.dart';

class WhatsAppMessageScreen extends StatefulWidget {
  final BusinessTask task;

  const WhatsAppMessageScreen({super.key, required this.task});

  @override
  State<WhatsAppMessageScreen> createState() => _WhatsAppMessageScreenState();
}

class _WhatsAppMessageScreenState extends State<WhatsAppMessageScreen> {
  late BusinessTask _currentTask;
  final TtsService _ttsService = TtsService();
  bool _isSpeaking = false;
  bool _isRegenerating = false;

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _currentTask.generatedMessage));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).translate('message_copied')),
        backgroundColor: AppTheme.accentGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _shareMessage() async {
    try {
      await Share.share(_currentTask.generatedMessage, subject: 'VyaparMitra Update');
    } catch (e) {
      debugPrint('Error sharing message: $e');
    }
  }

  Future<void> _toggleTts() async {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    if (_isSpeaking) {
      await _ttsService.stop();
      setState(() {
        _isSpeaking = false;
      });
    } else {
      setState(() {
        _isSpeaking = true;
      });
      await _ttsService.speak(_currentTask.generatedMessage, langProvider.languageCode);
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
      }
    }
  }

  Future<void> _regenerateMessage() async {
    setState(() {
      _isRegenerating = true;
    });

    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final aiProvider = Provider.of<AiProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    final newMsg = await aiProvider.regenerateTaskMessage(
      task: _currentTask,
      languageCode: langProvider.languageCode,
      ollamaUrl: settingsProvider.ollamaUrl,
      gemmaModel: settingsProvider.gemmaModel,
    );

    final updated = _currentTask.copyWith(generatedMessage: newMsg);
    if (_currentTask.id != null) {
      await taskProvider.updateTask(updated);
    }

    if (!mounted) return;
    setState(() {
      _currentTask = updated;
      _isRegenerating = false;
    });
  }

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: Text(
          loc.translate('whatsapp_message'),
          style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // WhatsApp Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF25D366), Color(0xFF128C7E)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF25D366).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.message_rounded, color: Colors.white, size: 32),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.translate('whatsapp_message'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Ready to copy or share with your customer',
                            style: TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Message Preview Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF25D366),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _currentTask.customerName ?? 'Customer',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: _isRegenerating
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.refresh, size: 20, color: AppTheme.primaryColor),
                          tooltip: loc.translate('regenerate'),
                          onPressed: _isRegenerating ? null : _regenerateMessage,
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    const SizedBox(height: 8),
                    SelectableText(
                      _currentTask.generatedMessage,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick Actions Grid (Copy, Share, Speak)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _copyToClipboard,
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: Text(loc.translate('copy')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _shareMessage,
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: Text(loc.translate('share')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _toggleTts,
                  icon: Icon(_isSpeaking ? Icons.stop_circle_outlined : Icons.volume_up_rounded, size: 20),
                  label: Text(_isSpeaking ? loc.translate('stop') : loc.translate('speak')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: const BorderSide(color: AppTheme.primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Back to Dashboard Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.home_outlined),
                  label: Text(loc.translate('home')),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
