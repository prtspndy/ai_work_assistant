import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/localization/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../providers/language_provider.dart';
import '../providers/voice_provider.dart';
import 'ai_processing_screen.dart';

class VoiceRecordScreen extends StatefulWidget {
  const VoiceRecordScreen({super.key});

  @override
  State<VoiceRecordScreen> createState() => _VoiceRecordScreenState();
}

class _VoiceRecordScreenState extends State<VoiceRecordScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isProcessingNav = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startVoiceRecognition();
    });
  }

  void _startVoiceRecognition() {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    final voiceProvider = Provider.of<VoiceProvider>(context, listen: false);
    voiceProvider.startListening(
      langProvider.languageCode,
      onComplete: _stopAndProcess,
    );
  }

  void _stopAndProcess() {
    if (_isProcessingNav) return;

    final voiceProvider = Provider.of<VoiceProvider>(context, listen: false);
    final text = voiceProvider.recognizedText.trim();
    voiceProvider.stopListening();

    if (text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).translate('tap_to_speak')),
            backgroundColor: AppTheme.accentOrange,
          ),
        );
      }
      return;
    }

    _isProcessingNav = true;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AIProcessingScreen(recognizedText: text),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    final voiceProvider = Provider.of<VoiceProvider>(context);

    final langNames = {'gu': 'ગુજરાતી', 'hi': 'हिंदी', 'en': 'English'};
    final currentLangLabel = langNames[langProvider.languageCode] ?? 'Gujarati';

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: Text(loc.translate('voice_record'), style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () {
            voiceProvider.cancelListening();
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Language Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.language, size: 18, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Language: $currentLangLabel',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Live Transcription Box
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              voiceProvider.isListening ? Icons.graphic_eq : Icons.edit_note,
                              color: voiceProvider.isListening ? AppTheme.accentGreen : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              voiceProvider.isListening
                                  ? loc.translate('listening')
                                  : loc.translate('tap_to_speak'),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: voiceProvider.isListening ? AppTheme.accentGreen : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Text(
                          voiceProvider.recognizedText.isNotEmpty
                              ? voiceProvider.recognizedText
                              : 'e.g. "કાલે મનોજભાઈને 25 box મોકલવાના છે, ₹12,500 payment pending છે."',
                          style: TextStyle(
                            fontSize: 18,
                            height: 1.5,
                            fontWeight: voiceProvider.recognizedText.isNotEmpty
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: voiceProvider.recognizedText.isNotEmpty
                                ? const Color(0xFF0F172A)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Microphone Pulsing Button
              GestureDetector(
                onTap: () {
                  if (voiceProvider.isListening) {
                    _stopAndProcess(); // Instantly process voice and give direct card!
                  } else {
                    _startVoiceRecognition();
                  }
                },
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    final scale = voiceProvider.isListening ? _pulseAnimation.value : 1.0;
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: voiceProvider.isListening
                              ? const LinearGradient(
                                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                                )
                              : AppTheme.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: (voiceProvider.isListening ? Colors.red : AppTheme.primaryColor).withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          voiceProvider.isListening ? Icons.stop_rounded : Icons.mic_rounded,
                          size: 42,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                voiceProvider.isListening ? loc.translate('tap_to_stop') : loc.translate('tap_to_speak'),
                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 30),

              // Continue / Direct Card Process Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: voiceProvider.recognizedText.trim().isNotEmpty ? _stopAndProcess : null,
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(loc.translate('continue_btn')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
