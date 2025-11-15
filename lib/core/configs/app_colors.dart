import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final class AppColors {
  // Primary agriculture green (Nepal hills, crops)
  static const Color primary = Color.fromARGB(255, 8, 134, 50);

  static const Color transparent = Color.fromARGB(0, 0, 0, 0);

  // iOS defaults
  static const Color iosBlack = CupertinoColors.darkBackgroundGray;
  static const Color iosWhite = CupertinoColors.lightBackgroundGray;

  // Core neutral colors
  static const Color black = Color(0xFF0D0D0D);
  static const Color white = Color(0xFFFFFFFF);

  // Nepal sky + water accent cyan
  static const Color cyan = Color(0xFF00BCD4);

  // App bar with Nepali-blue-inspired tone
  static const Color appBarColor = Color(0xFF003893); // Nepali flag blue

  // Soil-inspired brown
  static const Color reddisBrown = Color(0xFF7A4F27);

  // Mustard field light orange
  static const Color lightOrange = Color(0xFFFFD9A0);

  // Softer, modern title color for readability
  static const Color titleColor = Color(0xFF4F5B62);

  // Neutral border for clean UI
  static const Color borderColor = Color(0xFFE0E0E0);

  // Calm Nepali mountain blue-toned UI accent
  static const Color blue = Color(0xFF31406E);

  // Light and dark greys (unchanged variable names)
  static Color lightgrey = Colors.grey.shade100;
  static Color darkgrey = Colors.grey.shade900;
}
