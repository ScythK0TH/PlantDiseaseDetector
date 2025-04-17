import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color bgColor = Color(0xFFFFFFFF);
const Color primaryColor = Color(0xFF151C21);
const Color secondaryColor = Color(0xFFD9D9D9);
const Color successColor = Color.fromARGB(255, 76, 192, 107);
const Color alertColor = Color(0xFFEB5B40);

// Main Title
TextStyle mainTitleTextStyleDark({FontWeight fontWeight = FontWeight.normal}) =>
    GoogleFonts.inter(
      fontSize: 36,
      fontWeight: fontWeight,
      color: primaryColor,
      decoration: TextDecoration.none,
    );

TextStyle mainTitleTextStyleWhite(
        {FontWeight fontWeight = FontWeight.normal}) =>
    GoogleFonts.inter(
      fontSize: 36,
      fontWeight: fontWeight,
      color: bgColor,
      decoration: TextDecoration.none,
    );

// Subtitle
TextStyle subTitleTextStyleDark({FontWeight fontWeight = FontWeight.normal}) =>
    GoogleFonts.inter(
      fontSize: 24,
      fontWeight: fontWeight,
      color: primaryColor,
      decoration: TextDecoration.none,
    );

TextStyle subTitleTextStyleWhite({FontWeight fontWeight = FontWeight.normal}) =>
    GoogleFonts.inter(
      fontSize: 24,
      fontWeight: fontWeight,
      color: bgColor,
      decoration: TextDecoration.none,
    );

// Description
TextStyle descTextStyleDark({FontWeight fontWeight = FontWeight.normal}) =>
    GoogleFonts.inter(
      fontSize: 18,
      fontWeight: fontWeight,
      color: primaryColor,
      decoration: TextDecoration.none,
    );

TextStyle descTextStyleWhite({FontWeight fontWeight = FontWeight.normal}) =>
    GoogleFonts.inter(
      fontSize: 18,
      fontWeight: fontWeight,
      color: bgColor,
      decoration: TextDecoration.none,
    );

// Alert & Success
TextStyle alertTextStyle({FontWeight fontWeight = FontWeight.normal}) =>
    GoogleFonts.inter(
      fontSize: 18,
      fontWeight: fontWeight,
      color: alertColor,
      decoration: TextDecoration.none,
    );

TextStyle successTextStyle({FontWeight fontWeight = FontWeight.normal}) =>
    GoogleFonts.inter(
      fontSize: 18,
      fontWeight: fontWeight,
      color: successColor,
      decoration: TextDecoration.none,
    );
