import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'ai_processing_screen.dart';

class VoiceRecordScreen extends StatefulWidget {
  const VoiceRecordScreen({super.key});

  @override
  State<VoiceRecordScreen> createState() => _VoiceRecordScreenState();
}

class _VoiceRecordScreenState extends State<VoiceRecordScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late List<double> _waveHeights;
  Timer? _waveTimer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Pulse animation for the rings
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // Simulated wave heights
    _waveHeights = List.generate(7, (index) => 15.0 + _random.nextInt(45));
    _startWaveSimulation();
  }

  void _startWaveSimulation() {
    _waveTimer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      if (!mounted) return;
      setState(() {
        for (int i = 0; i < _waveHeights.length; i++) {
          _waveHeights[i] = 10.0 + _random.nextDouble() * 50.0;
        }
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveTimer?.cancel();
    super.dispose();
  }

  void _onStopRecording() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const AIProcessingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white.withOpacity(0.6),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.onSurface),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'VyaparMitra',
            style: TextStyle(
              color: AppTheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.black.withOpacity(0.05)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                    )
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    "https://lh3.googleusercontent.com/aida-public/AB6AXuBnAS_SI6wR4I-HbqzMXPZ1BhD4j2-yx0-rfT3FztgWevflHNcV2bKdPUccAjUBvVS_GUfjcbBLu2vk6PjP2qx1tVsMmFSX6tgD9uYnhAR8qM1UbY_RPm4UZPZp6QPi0uObT1VR1How4DjQcHGfoEWCEf_MGg81Fdh0hCdL6mCHZCvLcOei4nQEuibvy68tG5WCESbsqYq9PlaFaRNIE-Zhror4sdjOMAqXSPeU3KVugE7DnyTCH4g",
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: AppTheme.primary),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            // Ambient glow backings
            Positioned(
              top: 150,
              left: -150,
              child: Container(
                width: 500,
                height: 500,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x1A35AEEF), // primaryContainer with 0.1 opacity
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              right: -150,
              child: Container(
                width: 500,
                height: 500,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x1494DFFF), // secondaryContainer with 0.08 opacity
                ),
              ),
            ),

            // Main recording canvas
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  // Rippling Mic Circle
                  SizedBox(
                    width: 320,
                    height: 320,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Ripple Ring 3
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            double value = _pulseController.value;
                            return Opacity(
                              opacity: (1.0 - value) * 0.1,
                              child: Transform.scale(
                                scale: 1.0 + (value * 0.8),
                                child: Container(
                                  width: 260,
                                  height: 260,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        // Ripple Ring 2
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            double value = (_pulseController.value + 0.5) % 1.0;
                            return Opacity(
                              opacity: (1.0 - value) * 0.15,
                              child: Transform.scale(
                                scale: 1.0 + (value * 0.5),
                                child: Container(
                                  width: 220,
                                  height: 220,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.primaryContainer,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        // Core Mic Circle
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryContainer.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                            border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.mic,
                              size: 60,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Listening text
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '🎤 ',
                        style: TextStyle(fontSize: 22),
                      ),
                      Text(
                        'Listening...',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Gujarati helper subtitle
                  const Text(
                    'Speak in Gujarati / ગુજરાતીમાં બોલો',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Audio Visualizer Wave
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(_waveHeights.length, (index) {
                      Color barColor = AppTheme.primary;
                      if (index % 3 == 1) {
                        barColor = AppTheme.primaryContainer;
                      } else if (index % 3 == 2) {
                        barColor = AppTheme.secondary;
                      }

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        width: 10,
                        height: _waveHeights[index],
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: barColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: barColor.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 160), // Space to clear bottom panel
                ],
              ),
            ),

            // Fixed Bottom Panel with Action Buttons
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 40, top: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      const Color(0xFFDDF3FF),
                      const Color(0xFFDDF3FF).withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    // Stop button
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppTheme.skyGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryContainer.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            )
                          ],
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: ElevatedButton(
                          onPressed: _onStopRecording,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.stop_circle, size: 28),
                              SizedBox(width: 12),
                              Text(
                                'Stop Recording',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Status text
                    Text(
                      'System Processing Audio...',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurfaceVariant.withOpacity(0.8),
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
