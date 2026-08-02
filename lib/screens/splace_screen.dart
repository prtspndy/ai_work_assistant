import 'dart:math' as math;
import 'package:flutter/material.dart';

class SplaceScreen extends StatefulWidget {
  const SplaceScreen({super.key});

  @override
  State<SplaceScreen> createState() => _SplaceScreenState();
}

class _SplaceScreenState extends State<SplaceScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgAnimationController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Background Gradient & Shapes Animation Loop
    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    // Entry Fade & Scale Animation for Logo & Text
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeController.forward();

    // TODO: 3 થી 4 સેકન્ડ પછી હોમ સ્ક્રીન કે આગલી સ્ક્રીન પર નેવિગેટ કરવા માટે:
    /*
    Future.delayed(const Duration(seconds: 4), () {
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    });
    */
  }

  @override
  void dispose() {
    _bgAnimationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Dynamic Animated Gradient Background
          AnimatedBuilder(
            animation: _bgAnimationController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF0F172A), // Deep Slate Navy
                      Color.lerp(
                        const Color(0xFF1E1B4B),
                        const Color(0xFF31103F),
                        _bgAnimationController.value,
                      )!,
                      const Color(0xFF0284C7), // Vibrant Teal / Blue Accent
                    ],
                  ),
                ),
              );
            },
          ),

          // 2. Animated Background AI Light Orbs (Gemma Vibe)
          AnimatedBuilder(
            animation: _bgAnimationController,
            builder: (context, child) {
              return CustomPaint(
                size: size,
                painter: BackgroundOrbPainter(
                  progress: _bgAnimationController.value,
                ),
              );
            },
          ),

          // 3. Foreground Responsive Content
          SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? size.width * 0.15 : 24.0,
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),

                        // Premium App Logo Frame with Glow
                        Container(
                          width: isTablet ? 150 : 110,
                          height: isTablet ? 150 : 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF38BDF8), Color(0xFF818CF8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF38BDF8).withOpacity(0.4),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.record_voice_over_rounded,
                              size: isTablet ? 70 : 50,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // App Main Name
                        Text(
                          "Vyapar Vani", // તમે તમારી એપનું નામ અહીં બદલી શકો છો
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 38 : 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Gujarati + English Subtitle
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                            ),
                          ),
                          child: Text(
                            "બોલો અને ટાસ્ક બનાવો • AI Assistant",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF38BDF8),
                              fontSize: isTablet ? 18 : 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Brief Target User Description Text
                        Text(
                          "દુકાનદારો, વેપારીઓ અને લોકલ બિઝનેસ માટે ખાસ",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: isTablet ? 16 : 13,
                          ),
                        ),

                        const Spacer(),

                        // Bottom Powered By Gemma Tag & Loader
                        Column(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  const Color(0xFF38BDF8).withOpacity(0.8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 16,
                                  color: Colors.amber.shade300,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Powered by Gemma AI",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Background Custom Painter for Dynamic Ambient Lights
class BackgroundOrbPainter extends CustomPainter {
  final double progress;

  BackgroundOrbPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = const Color(0xFF38BDF8).withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    final paint2 = Paint()
      ..color = const Color(0xFFA855F7).withOpacity(0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);

    // Floating orb 1
    double x1 = size.width * 0.2 + math.sin(progress * math.pi * 2) * 40;
    double y1 = size.height * 0.3 + math.cos(progress * math.pi * 2) * 30;
    canvas.drawCircle(Offset(x1, y1), size.width * 0.35, paint1);

    // Floating orb 2
    double x2 = size.width * 0.8 - math.cos(progress * math.pi * 2) * 30;
    double y2 = size.height * 0.7 - math.sin(progress * math.pi * 2) * 40;
    canvas.drawCircle(Offset(x2, y2), size.width * 0.45, paint2);
  }

  @override
  bool shouldRepaint(covariant BackgroundOrbPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}