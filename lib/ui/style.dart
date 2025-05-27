import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  //Global Theme Color
  static const Color primaryColor = Color(0xFF6CC964);
  static const Color secondaryColor = Color(0xFFD9D9D9);
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

  //Dark Color
  static const Color dark = Color(0xFF000000);

  //ThemeData for Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: light,
  );

  //ThemeData for Dark Theme
  static final ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: dark);

  //Font Setting
  TextStyle largeTitleLight(
    BuildContext context,
  ) {
    return GoogleFonts.inter(
      fontSize: 30,
      fontWeight: FontWeight.bold,
      color: light,
    );
  }

  TextStyle mediumTitleLight(
    BuildContext context,
  ) {
    return GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: light,
    );
  }

  TextStyle smallTitleLight(
    BuildContext context,
  ) {
    return GoogleFonts.inter(
        fontSize: 18, fontWeight: FontWeight.bold, color: light);
  }

  TextStyle largeTitleDark(
    BuildContext context,
  ) {
    return GoogleFonts.inter(
      fontSize: 30,
      fontWeight: FontWeight.bold,
      color: dark,
    );
  }

  TextStyle mediumTitleDark(
    BuildContext context,
  ) {
    return GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: dark,
    );
  }

  TextStyle smallTitleDark(
    BuildContext context,
  ) {
    return GoogleFonts.inter(
        fontSize: 18, fontWeight: FontWeight.bold, color: dark);
  }

  TextStyle hightlightLarge(
    BuildContext context,
  ) {
    return GoogleFonts.inter(
        fontSize: 30, fontWeight: FontWeight.bold, color: primaryColor);
  }

  TextStyle hightlightMedium(
    BuildContext context,
  ) {
    return GoogleFonts.inter(
        fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor);
  }

  TextStyle hightlightSmall(
    BuildContext context,
  ) {
    return GoogleFonts.inter(
        fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor);
  }

  TextStyle contentLight(
    BuildContext context,
  ) {
    return GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.normal, color: light);
  }

    TextStyle contentDark(
    BuildContext context,
  ) {
    return GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.normal, color: dark);
  }
}
