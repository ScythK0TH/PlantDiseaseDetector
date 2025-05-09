import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_pdd/widget/first_page.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

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
        navigatorObservers: [routeObserver], // <-- Add this line
        routes: {
          '/': (context) => FirstPageScreen(),
        });
  }
}
