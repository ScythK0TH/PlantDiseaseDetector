import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_pdd/style.dart';
import 'package:project_pdd/widget/first_page.dart';
import 'package:project_pdd/widget/recogniser.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Project PDD',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            textTheme: GoogleFonts.promptTextTheme(),
          ),
          themeMode: mode,
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            textTheme: GoogleFonts.promptTextTheme(
              TextTheme(
                bodySmall: const TextStyle(color: Colors.white),
                bodyMedium: const TextStyle(color: Colors.white),
                bodyLarge: const TextStyle(color: Colors.white),
              ),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: primaryColor,
            ),
            scaffoldBackgroundColor: primaryColor,
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: primaryColor,
              unselectedIconTheme: IconThemeData(color: Colors.white),
            ),
          ),
          initialRoute: '/',
          navigatorObservers: [routeObserver],
          routes: {
            '/': (context) => FirstPageScreen(),
          },
        );
      },
    );
  }
}
