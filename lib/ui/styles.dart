import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  //Global Theme Color
  static const Color primaryColor = Color(0xFF6CC964);
  static const Color alertColor = Color(0xFFE56767);

  //Gradient Color
  static const LinearGradient primaryGradient = LinearGradient(
      colors: [Color(0xFF6CC964), Color(0xFF89C584)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight);

  static const LinearGradient secondaryGradient = LinearGradient(
      colors: [Color(0xFF6CC964), Color(0xFFCAEDC7)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter);

  static const LinearGradient thirtyGradient = LinearGradient(
      colors: [Color(0xFF6CC964), Color(0xFF89C584)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter);

  //Light Color (Default)
  static const Color light = Color(0xFFFFFFFF);
  static const Color lightInverse = Color(0x1FFFFFFF);

  //Dark Color
  static const Color dark = Color(0xFF000000);
  static const Color darkInverse = Color(0xFFD9D9D9);

  //ThemeData for Light Theme and Dark Theme
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color themedIconColor(BuildContext context) {
    return isDarkMode(context) ? light : dark;
  }

  static Color themedBgIconColor(BuildContext context) {
    return isDarkMode(context) ? lightInverse : darkInverse;
  }

  //Font Setting
  static TextStyle largeTitle(
    BuildContext context,
  ) {
    return GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : dark);
  }

  static TextStyle mediumTitle(
    BuildContext context,
  ) {
    return GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : dark);
  }

  static TextStyle smallTitle(
    BuildContext context,
  ) {
    return GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : dark);
  }

  static TextStyle hightlightLarge(
    BuildContext context,
  ) {
    return GoogleFonts.inter(
        fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor);
  }

  static TextStyle hightlightMedium(
    BuildContext context,
  ) {
    return GoogleFonts.inter(
        fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor);
  }

  static TextStyle hightlightSmall(
    BuildContext context,
  ) {
    return GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor);
  }

  static TextStyle content(
    BuildContext context,
  ) {
    return GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : dark);
  }
}
