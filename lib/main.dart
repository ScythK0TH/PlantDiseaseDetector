import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_pdd/widget/first_page.dart';
import 'package:project_pdd/widget/recogniser.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textTheme: GoogleFonts.promptTextTheme(),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => FirstPageScreen(),
          '/recogniser': (context) => Recogniser(),
        });
  }
}
