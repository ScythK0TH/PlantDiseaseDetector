import 'dart:ui';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:project_pdd/storage_page.dart';
import 'login.dart';
import 'register.dart';

class FirstPageScreen extends StatefulWidget {
  const FirstPageScreen({super.key});

  @override
  FirstPageScreenState createState() => FirstPageScreenState();
}

class FirstPageScreenState extends State<FirstPageScreen> {
  final List<String> textSequence = [
    "Welcome to our app!!",
    "Let's get started!!",
    "Build something great!!",
    "Join us today!!"
  ];
  int index = 0;

  void _changeText() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          index = (index + 1) % textSequence.length;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // พื้นหลังเดียวกันสำหรับทั้งสองส่วน
          Container(
            height: screenHeight,
            width: screenWidth,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xffa8d5ba), // เขียวพาสเทลอ่อน
                  Color(0xff77c1a4), // เขียวพาสเทลเข้ม
                  Color(0xff4cb3b1), // เขียวพาสเทลมืด
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // ส่วนแรกของเนื้อหา
          Column(
            children: [
              Flexible(
                flex: 4,
                child: Padding(
                  padding: EdgeInsets.only(top: 30.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(
                      'assets/images/plantFirstPage.png',
                      width: 300.0,
                      height: 300.0,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              // เพิ่มชื่อแอพใต้ภาพ
              Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Text(
                  "Plant Hub", // ชื่อแอพที่คุณต้องการ
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 35.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Flexible(
                flex: 1, // เพิ่มส่วนนี้สำหรับข้อความที่พิมพ์
                child: Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 250),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: Container(
                      key: ValueKey<int>(index), // Forces rebuild
                      child: AnimatedTextKit(
                        animatedTexts: [
                          TypewriterAnimatedText(
                            textSequence[index],
                            textStyle:
                                TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 35.0),
                            speed: Duration(milliseconds: 200),
                            cursor: '|',  // Cursor ที่ท้ายข้อความ
                          ),
                        ],
                        isRepeatingAnimation: false,
                        onFinished: _changeText,
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 6,
                child: Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.23),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 255, 255, 255),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                          minimumSize: Size(0.70 * screenWidth, 55.0),
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            isScrollControlled: true,
                            context: context, // Allow modal to resize with keyboard
                            backgroundColor: Colors.transparent, // Make modal transparent
                            builder: (BuildContext context) {
                              double keyboardHeight = MediaQuery.of(context).viewInsets.bottom; // Detect keyboard height
                              return SizedBox(
                                height: keyboardHeight > 0 ? MediaQuery.of(context).size.height * 0.9 : MediaQuery.of(context).size.height * 0.6, // Increase height when keyboard appears
                                child: Stack(
                                  children: [
                                    // Blur effect
                                    BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                      child: Container(
                                        color: Colors.transparent,
                                      ),
                                    ),
                                    // Modal content
                                    Positioned(
                                      child: RegisApp(),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(color: Color(0xFF464646), fontSize: 16),
                        ),
                      ),
                      SizedBox(height: 15),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                          minimumSize: Size(0.70 * screenWidth, 55.0),
                          side: BorderSide(
                            color: Color.fromARGB(255, 255, 255, 255), // สีของเส้นขอบ
                            width: 2.0, // ความหนาของเส้นขอบ
                          ),
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            isScrollControlled: true,
                            context: context, // Allow modal to resize with keyboard
                            backgroundColor: Colors.transparent, // Make modal transparent
                            builder: (BuildContext context) {
                              double keyboardHeight = MediaQuery.of(context).viewInsets.bottom; // Detect keyboard height
                              return SizedBox(
                                height: keyboardHeight > 0 ? MediaQuery.of(context).size.height * 0.85 : MediaQuery.of(context).size.height * 0.55, // Increase height when keyboard appears
                                child: Stack(
                                  children: [
                                    // Blur effect
                                    BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                      child: Container(
                                        color: Colors.transparent,
                                      ),
                                    ),
                                    // Modal content
                                    Positioned(
                                      child: LoginApp(),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: Text(
                          'Log In',
                          style:
                              TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 16),
                        ),
                      ),
                      SizedBox(height: 15),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StoragePage())
                          );
                        },
                        child: Text(
                          'Continue without an account',
                          style: TextStyle(color: Color(0xFF444444)),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
