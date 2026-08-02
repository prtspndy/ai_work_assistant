import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/localization/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../providers/language_provider.dart';
import 'home_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  final bool isFromSettings;

  const LanguageSelectionScreen({super.key, this.isFromSettings = false});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  late String _selectedLangCode;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<LanguageProvider>(context, listen: false);
    _selectedLangCode = provider.languageCode;
  }

  void _onLanguageSelected(String code) {
    setState(() {
      _selectedLangCode = code;
    });
  }

  Future<void> _proceed() async {
    final provider = Provider.of<LanguageProvider>(context, listen: false);
    await provider.setLanguage(_selectedLangCode);
    if (provider.isFirstRun) {
      await provider.completeFirstRun();
    }

    if (!mounted) return;
    if (widget.isFromSettings) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    final List<Map<String, String>> languages = [
      {'code': 'gu', 'name': 'ગુજરાતી', 'sub': 'Gujarati', 'native': 'તમારું વ્યવસાય સહાયક'},
      {'code': 'hi', 'name': 'हिंदी', 'sub': 'Hindi', 'native': 'आपका व्यापार सहायक'},
      {'code': 'en', 'name': 'English', 'sub': 'English', 'native': 'Your Business Assistant'},
    ];

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.translate_rounded,
                  size: 36,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                loc.translate('select_language'),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                loc.translate('choose_preferred_language'),
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 30),

              // Language Cards
              Expanded(
                child: ListView.builder(
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    final item = languages[index];
                    final isSelected = _selectedLangCode == item['code'];

                    return GestureDetector(
                      onTap: () => _onLanguageSelected(item['code']!),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryColor : const Color(0xFFE2E8F0),
                            width: isSelected ? 2.5 : 1.0,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppTheme.primaryColor.withOpacity(0.15),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  )
                                ]
                              : [],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : const Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  item['code']!.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name']!,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? AppTheme.primaryColor
                                          : const Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item['native']!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppTheme.primaryColor,
                                size: 28,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _proceed,
                  child: Text(loc.translate('continue_btn')),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
