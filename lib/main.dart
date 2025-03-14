import 'package:flutter/material.dart';
import 'storage_page.dart';
import 'details_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => StoragePage(),
        '/details': (context) => DetailsPage(),
      },
    );
  }
}
