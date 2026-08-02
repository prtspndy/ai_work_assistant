import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF35AEEF);
  static const Color secondary = Color(0xFF0073B7);
  static const Color onSurface = Color(0xFF111827);
  static const Color onSurfaceVariant = Color(0xFF6B7280);
  static const Color surfaceContainerHigh = Color(0xFFF1F5F9); 
  static const Color secondaryContainer = Color(0xFFE0F2FE);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color error = Color(0xFFDC2626);
  static const Color surfaceContainerLow = Color(0xFFF8FAFC);
  static const Color surfaceContainerHighest = Color(0xFFE2E8F0);

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFF8FCFF), Color(0xFFDDF3FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const Color primaryContainer = Color(0xFFE0F2FE);

  static const LinearGradient skyGradient = LinearGradient(
    colors: [Color(0xFF29B6F6), Color(0xFF0277BD)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
