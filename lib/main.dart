import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_pdd/home.dart';
import 'package:project_pdd/services/database.dart';
import 'package:project_pdd/style.dart';
import 'package:flutter/services.dart';
import 'package:project_pdd/widget/first_page.dart';
import 'package:project_pdd/widget/gemini.dart';
import 'package:project_pdd/widget/recogniser.dart';
import 'package:project_pdd/widget/storage_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);
final imageCountUpdateNotifier = ValueNotifier<int>(0);
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

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
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await dotenv.load(fileName: "assets/.env");
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en', 'US'), Locale('th', 'TH')],
      path: 'assets/languages',
      fallbackLocale: const Locale('en', 'US'),
      startLocale: const Locale('th', 'TH'),
      child: MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  String? userId;
  ThemeMode themeMode = ThemeMode.light;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    userId = await getSavedUserId();
    themeMode = await loadThemeMode();
    await MongoService().connect();
    setState(() {
      isLoading = false;
      themeModeNotifier.value = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }
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
          navigatorObservers: [routeObserver],
        );
      },
    );
  }
}
