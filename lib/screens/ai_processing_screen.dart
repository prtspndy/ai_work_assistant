import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/localization/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../providers/ai_provider.dart';
import '../providers/language_provider.dart';
import '../providers/settings_provider.dart';
import 'edit_task_screen.dart';

class AIProcessingScreen extends StatefulWidget {
  final String recognizedText;

  const AIProcessingScreen({super.key, required this.recognizedText});

  @override
  State<AIProcessingScreen> createState() => _AIProcessingScreenState();
}

class _AIProcessingScreenState extends State<AIProcessingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAIProcessing();
    });
  }

  Future<void> _startAIProcessing() async {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final aiProvider = Provider.of<AiProvider>(context, listen: false);

    final success = await aiProvider.processSpeechToTask(
      speechText: widget.recognizedText,
      languageCode: langProvider.languageCode,
      ollamaUrl: settingsProvider.ollamaUrl,
      gemmaModel: settingsProvider.gemmaModel,
    );

    if (!mounted) return;

    if (success && aiProvider.extractedTask != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EditTaskScreen(task: aiProvider.extractedTask!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final aiProvider = Provider.of<AiProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Processing AI Graphic
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 25,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 56,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              Text(
                loc.translate('processing_ai'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Model: ${settingsProvider.gemmaModel}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),

              // Animated Step Indicator
              _buildStepTile(
                stepIndex: 1,
                title: loc.translate('step_speech'),
                isActive: aiProvider.currentStep == ProcessingStep.speech,
                isDone: aiProvider.currentStep.index > ProcessingStep.speech.index,
              ),
              const SizedBox(height: 16),
              _buildStepTile(
                stepIndex: 2,
                title: loc.translate('step_ai'),
                isActive: aiProvider.currentStep == ProcessingStep.aiExtraction,
                isDone: aiProvider.currentStep.index > ProcessingStep.aiExtraction.index,
              ),
              const SizedBox(height: 16),
              _buildStepTile(
                stepIndex: 3,
                title: loc.translate('step_task'),
                isActive: aiProvider.currentStep == ProcessingStep.preparingTask,
                isDone: aiProvider.currentStep.index > ProcessingStep.preparingTask.index,
              ),

              const Spacer(),

              // Friendly Error Card with Retry Button
              if (aiProvider.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.accentRed.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.accentRed.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.wifi_off_rounded, color: AppTheme.accentRed, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'AI Offline / Connection Failed',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF991B1B),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  aiProvider.errorMessage!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF7F1D1D),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              aiProvider.reset();
                              Navigator.pop(context);
                            },
                            child: Text(loc.translate('cancel')),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _startAIProcessing,
                            icon: const Icon(Icons.refresh, size: 16),
                            label: Text(loc.translate('retry')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentRed,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                          ),
                        ],
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

  Widget _buildStepTile({
    required int stepIndex,
    required String title,
    required bool isActive,
    required bool isDone,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? AppTheme.primaryColor : const Color(0xFFE2E8F0),
          width: isActive ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isDone
                  ? AppTheme.accentGreen
                  : isActive
                      ? AppTheme.primaryColor
                      : const Color(0xFFCBD5E1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isDone
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text(
                      '$stepIndex',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive || isDone ? FontWeight.bold : FontWeight.normal,
                color: isActive || isDone ? const Color(0xFF0F172A) : const Color(0xFF64748B),
              ),
            ),
          ),
          if (isActive)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor)),
            ),
        ],
      ),
    );
  }
}
