import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_pdd/style.dart';
import 'package:flutter/services.dart';
import 'package:project_pdd/widget/first_page.dart';
import 'package:project_pdd/widget/recogniser.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Set the preferred orientations to portrait mode only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
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
            brightness: Brightness.light,
            textTheme: GoogleFonts.promptTextTheme(),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
            ),
            scaffoldBackgroundColor: Colors.white,
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
            ),
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
