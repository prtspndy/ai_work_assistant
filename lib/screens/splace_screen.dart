import 'dart:async';
import 'package:flutter/material.dart';

import 'language_selection_screen.dart';

// ----------------------------------------------------
// Main Premium Light Splash Screen
// ----------------------------------------------------
class SplaceScreen extends StatefulWidget {
  const SplaceScreen({super.key});

  @override
  State<SplaceScreen> createState() => _SplaceScreenState();
}

class _SplaceScreenState extends State<SplaceScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _logoScale;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Entrance animation configuration
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _mainController.forward();

    // 3 સેકન્ડ પછી સ્મૂધલી Login Screen પર Navigate થશે
    Timer(const Duration(seconds: 10), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
            const ChooseLanguageScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      body: Container(
        // Soft Light Gradient Background (#F8FCFF -> #DDF3FF)
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FCFF), Color(0xFFDDF3FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // 1. Soft Cyan Background Ambient Glow
            Positioned(
              top: size.height * 0.22,
              left: size.width * 0.5 - (isTablet ? 200 : 125),
              child: Container(
                width: isTablet ? 400 : 250,
                height: isTablet ? 400 : 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8DD8F8).withOpacity(0.35),
                      blurRadius: 100,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),

            // 2. Main Content Layout
            SafeArea(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? size.width * 0.2 : 32.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 3),

                      // Pure White Card Logo Frame with Light Blue Shadow
                      ScaleTransition(
                        scale: _logoScale,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            width: isTablet ? 120 : 96,
                            height: isTablet ? 120 : 96,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.0),
                              border: Border.all(
                                color: const Color(0xFFDCEAF2),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF35AEEF).withOpacity(0.15),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/logo/app_icon.png',
                                width: isTablet ? 80 : 60,
                                height: isTablet ? 80 : 60,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // App Title and Subtitles with Animation
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              // App Main Title
                              Text(
                                "Vyapar Vani",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFF111827), // Near Black
                                  fontSize: isTablet ? 36 : 28,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Subtitle Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF35AEEF).withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(20.0),
                                  border: Border.all(
                                    color: const Color(0xFFDCEAF2),
                                    width: 1.0,
                                  ),
                                ),
                                child: Text(
                                  "AI Voice Task Manager",
                                  style: TextStyle(
                                    color: const Color(0xFF35AEEF),
                                    fontSize: isTablet ? 14 : 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Gujarati Description
                              Text(
                                "ગુજરાતી બોલીમાંથી ઓટોમેટિક ટાસ્ક અને ઓર્ડર બનાવો",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFF6B7280), // Cool Gray
                                  fontSize: isTablet ? 16 : 14,
                                  height: 1.4,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(flex: 3),

                      // Bottom Sleek Progress Indicator & Gemma Badge
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            // Linear Progress Bar
                            SizedBox(
                              width: isTablet ? 180 : 120,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: const LinearProgressIndicator(
                                  minHeight: 4,
                                  backgroundColor: Color(0xFFDCEAF2),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF35AEEF),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Gemma AI Tagline
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.auto_awesome,
                                  size: 15,
                                  color: Color(0xFFF59E0B),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "POWERED BY GEMMA AI",
                                  style: TextStyle(
                                    color: const Color(0xFF6B7280),
                                    fontSize: isTablet ? 12 : 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}