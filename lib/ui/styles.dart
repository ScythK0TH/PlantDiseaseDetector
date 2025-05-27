import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  //Global Theme Color
  static const Color primaryColor = Color(0xFF6CC964);
  static const Color alertColor = Color(0xFFE56767);

  //Gradient Color
  static const LinearGradient primaryGradient = LinearGradient(
      colors: [Color(0xFF6CC964), Color.fromARGB(255, 146, 199, 141)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight);

  static const LinearGradient secondaryGradient = LinearGradient(
      colors: [Color(0xFF6CC964), Color.fromRGBO(169, 216, 165, 1)],
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

  static Color selectedIconColor(BuildContext context) {
    return isDarkMode(context) ? dark : light;
  }

  static Color themedIconColor(BuildContext context) {
    return isDarkMode(context) ? light : dark;
  }

  static Color themedBgIconColor(BuildContext context) {
    return isDarkMode(context) ? lightInverse : darkInverse;
  }

  //Font Setting
  static TextStyle largeTitle(
    BuildContext context, {
    Color? color,
  }) {
    return GoogleFonts.kanit(
      fontSize: 28,
      fontWeight: FontWeight.w500,
      color: color ??
          (Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : dark),
    );
  }

  static TextStyle mediumTitle(
    BuildContext context, {
    Color? color,
  }) {
    return GoogleFonts.kanit(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      color: color ??
          (Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : dark),
    );
  }

  static TextStyle smallTitle(
    BuildContext context, {
    Color? color,
  }) {
    return GoogleFonts.kanit(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: color ??
          (Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : dark),
    );
  }

  static TextStyle largeContent(
    BuildContext context, {
    Color? color,
  }) {
    return GoogleFonts.kanit(
      fontSize: 28,
      fontWeight: FontWeight.normal,
      color: color ??
          (Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : dark),
    );
  }

  static TextStyle mediumContent(
    BuildContext context, {
    Color? color,
  }) {
    return GoogleFonts.kanit(
      fontSize: 22,
      fontWeight: FontWeight.normal,
      color: color ??
          (Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : dark),
    );
  }

  static TextStyle smallContent(
    BuildContext context, {
    Color? color,
  }) {
    return GoogleFonts.kanit(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: color ??
          (Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : dark),
    );
  }
}
