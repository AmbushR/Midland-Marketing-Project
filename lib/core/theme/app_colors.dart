import 'package:flutter/material.dart';

/// Design tokens used across the whole app.
class AppColors {
  const AppColors._();

  /*  static const primary = Color(0xFF4F46E5);
  static const primaryDark = Color(0xFF3730A3);*/
  static const primary = Color(0xFF0D9488); // main teal (buttons, links, focus)
  static const primaryDark = Color(0xFF0F766E);
  static const violet = Color(0xFF7C3AED);
  static const teal = Color(0xFF0D9488);
  static const rose = Color(0xFFE11D48);

  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const orange = Color(0xFFF97316);
  static const danger = Color(0xFFEF4444);

  static const ink = Color(0xFF111827);
  static const muted = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
  static const background = Color(0xFFF4F5FB);

  /*
  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3730A3), Color(0xFF6D4AE8), Color(0xFF8B5CF6)],
  );
*/
  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0F766E),
      Color(0xFF0D9488),
      Color(0xFF34D399),
    ], // teal → green
  );
  static const softShadow = [
    BoxShadow(color: Color(0x141E1B4B), blurRadius: 24, offset: Offset(0, 8)),
  ];
}
