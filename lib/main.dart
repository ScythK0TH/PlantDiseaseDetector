import 'package:flutter/material.dart';
import 'package:project_pdd/camera.dart';
import 'package:project_pdd/first_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => FirstPageScreen(),
        '/camera': (context) => CameraScreen(),
      },
    );
  }
}
