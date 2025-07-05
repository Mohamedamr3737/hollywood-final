import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors
  static Color primaryColor = const Color(0xFF2E7D8F), // Professional teal
      primaryDark = const Color(0xFF1A5A6B),
      primaryLight = const Color(0xFF4A9BAE),
      
  // Secondary colors
      accentColor = const Color(0xFFFF6B35), // Warm orange accent
      accentLight = const Color(0xFFFF8A65),
      
  // Neutral colors
      backgroundColor = const Color(0xFFF8FAFB),
      surfaceColor = Colors.white,
      cardColor = Colors.white,
      
  // Text colors
      textPrimary = const Color(0xFF1A1A1A),
      textSecondary = const Color(0xFF6B7280),
      textLight = const Color(0xFF9CA3AF),
      
  // Status colors
      successColor = const Color(0xFF10B981),
      warningColor = const Color(0xFFF59E0B),
      errorColor = const Color(0xFFEF4444),
      infoColor = const Color(0xFF3B82F6),
      
  // Legacy colors (keeping for compatibility)
      primeryColor = const Color(0xFF2E7D8F),
      greenColor = const Color(0xFF10B981),
      bgColor = const Color(0xFFF8FAFB),
      whiteColor = Colors.white,
      textcolor = const Color(0xFF1A1A1A),
      redcolor = const Color(0xFFEF4444),
      bgDarkColor = const Color(0xFFE5E7EB);
      
  // Gradient colors
  static LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient accentGradient = LinearGradient(
    colors: [accentColor, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color primary = Colors.orange;
  static const Color secondary = Colors.orangeAccent;
  static const Color background = Colors.white;
  static const Color text = Colors.black;
  static const Color error = Colors.red;
  // Add more as needed
}
