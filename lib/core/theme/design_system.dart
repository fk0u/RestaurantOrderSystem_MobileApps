import 'package:flutter/material.dart';

class AppDimens {
  // Golden Ratio Spacing
  static const double s8 = 8.0;
  static const double s13 = 13.0; // 8 * 1.618
  static const double s21 = 21.0; // 13 * 1.618
  static const double s34 = 34.0; // 21 * 1.618
  static const double s55 = 55.0; // 34 * 1.618
  
  // Radius
  static const double r16 = 16.0;
  static const double r24 = 24.0;
  static const double r32 = 32.0;
  
  // Icon
  static const double iconSmall = 20.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
}

class AppShadows {
  static final List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];
  
  static final List<BoxShadow> float = [
    BoxShadow(
      color: const Color(0xFF7CB342).withOpacity(0.3), // Primary shadow
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
  
  static final List<BoxShadow> dock = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 30,
      offset: const Offset(0, -5),
    ),
  ];
}
