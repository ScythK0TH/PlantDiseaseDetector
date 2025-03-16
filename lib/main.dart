import 'package:flutter/material.dart';
import 'package:project_pdd/camera.dart';
import 'package:project_pdd/details_page.dart';
import 'package:project_pdd/first_page.dart';
import 'package:project_pdd/storage_page.dart';
import 'package:sizer/sizer.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            '/': (context) => FirstPageScreen(),
            '/storage': (context) => StoragePage(),
            '/details': (context) => DetailsPage(),
            '/camera': (context) => CameraScreen()
          }
        );
      }
    );
  }
}