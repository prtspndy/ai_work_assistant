import 'package:flutter/material.dart';
import 'home_screen.dart';

class ChooseLanguageScreen extends StatefulWidget {
  const ChooseLanguageScreen({super.key});

  @override
  State<ChooseLanguageScreen> createState() => _ChooseLanguageScreenState();
}

class _ChooseLanguageScreenState extends State<ChooseLanguageScreen> {
  // Track selected language index (Default: English - index 0)
  int selectedIndex = 0;

  final List<Map<String, String>> languages = [
    {'title': 'English', 'subtitle': 'Continue in English', 'badge': 'En'},
    {'title': 'ગુજરાતી', 'subtitle': 'ગુજરાતીમાં ચાલુ રાખો', 'badge': 'ગુ'},
    {'title': 'हिंदी', 'subtitle': 'हिंदी में जारी रखें', 'badge': 'हि'},
  ];

  @override
  Widget build(BuildContext context) {
    // Theme Colors
    const primaryBlue = Color(0xFF35AEEF);
    const softCyan = Color(0xFF8DD8F8);
    const surfaceWhite = Color(0xFFFFFFFF);
    const primaryText = Color(0xFF111827);
    const secondaryText = Color(0xFF6B7280);
    const borderColor = Color(0xFFDCEAF2);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FCFF),
              Color(0xFFDDF3FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Header Icon Box
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: softCyan.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.g_translate_rounded,
                    color: primaryBlue,
                    size: 32,
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                const Text(
                  'Choose Language',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: primaryText,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 12),

                // Subtitle
                const Text(
                  'Select your preferred language to customize your experience.',
                  style: TextStyle(
                    fontSize: 16,
                    color: secondaryText,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 32),

                // Language Cards List
                Expanded(
                  child: ListView.separated(
                    itemCount: languages.length,
                    separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final isSelected = selectedIndex == index;
                      final item = languages[index];

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: surfaceWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? primaryBlue : borderColor,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? primaryBlue.withValues(alpha: 0.12)
                                    : Colors.black.withValues(alpha: 0.03),
                                blurRadius: isSelected ? 12 : 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Text Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title']!,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? primaryBlue
                                            : primaryText,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['subtitle']!,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Language Badge Box
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? softCyan.withValues(alpha: 0.3)
                                      : const Color(0xFFF3F8FC),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  item['badge']!,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? primaryBlue
                                        : secondaryText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Confirm Selection Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      elevation: 4,
                      shadowColor: primaryBlue.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Confirm Selection',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}