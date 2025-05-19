import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_pdd/home.dart';
import 'package:project_pdd/style.dart';
import 'package:flutter/services.dart';
import 'package:project_pdd/widget/first_page.dart';
import 'package:project_pdd/widget/gemini.dart';
import 'package:project_pdd/widget/recogniser.dart';
import 'package:project_pdd/widget/storage_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

Future<String?> getSavedUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userId');
}

Future<void> saveThemeMode(ThemeMode mode) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('themeMode', mode == ThemeMode.dark ? 'dark' : 'light');
}

Future<ThemeMode> loadThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  final theme = prefs.getString('themeMode');
  if (theme == 'dark') return ThemeMode.dark;
  return ThemeMode.light;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  final userId = await getSavedUserId();
  final themeMode = await loadThemeMode();
  // Set the preferred orientations to portrait mode only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await dotenv.load(fileName: "assets/.env");
  runApp(EasyLocalization(
    supportedLocales: const [Locale('en', 'US'), Locale('th', 'TH')],
    path: 'assets/languages',
    fallbackLocale: const Locale('en', 'US'),
    startLocale: const Locale('th', 'TH'),
    child: MainApp(userId: userId, initialThemeMode: themeMode)));
}

class MainApp extends StatelessWidget {
  final String? userId;
  final ThemeMode initialThemeMode;
  const MainApp({super.key, required this.userId, required this.initialThemeMode});

  @override
  Widget build(BuildContext context) {
    // Set the initial theme mode based on the saved preference
    themeModeNotifier.value = initialThemeMode;
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
          home: userId == null
              ? FirstPageScreen()
              : HomePage(userId: userId!),
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
        );
      },
    );
  }
}
