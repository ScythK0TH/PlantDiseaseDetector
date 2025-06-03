import 'dart:ui';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:project_pdd/main.dart';
import 'package:project_pdd/ui/styles.dart';
import 'package:project_pdd/widget/tos_page.dart';
import 'login.dart';
import 'register.dart';

class FirstPageScreen extends StatefulWidget {
  const FirstPageScreen({super.key});

  @override
  FirstPageScreenState createState() => FirstPageScreenState();
}

class FirstPageScreenState extends State<FirstPageScreen> {
  final List<String> textSequence = [
    "Welcome to our app!!".tr(),
    "Let's get started!!".tr(),
    "Build something great!!".tr(),
    "Join us today!!".tr()
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Theme.of(context).brightness == Brightness.dark) {
        themeModeNotifier.value = ThemeMode.light;
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
            decoration: BoxDecoration(gradient: AppTheme.firstPageGradient),
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
                child: Text('BaiRooRok'.tr(),
                    style: context.locale.languageCode == 'en'
                        ? AppTheme.titleFirstPageEN(context,
                            color: AppTheme.light)
                        : AppTheme.titleFirstPageTH(context,
                            color: AppTheme.light)),
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
                            textStyle: AppTheme.mediumTitle(context,color: AppTheme.light),
                            speed: Duration(milliseconds: 200),
                            cursor: '|', // Cursor ที่ท้ายข้อความ
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
                          backgroundColor: AppTheme.themedBgColor(context),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(36.0),
                          ),
                          minimumSize: Size(0.70 * screenWidth, 55.0),
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            isScrollControlled: true,
                            context:
                                context, // Allow modal to resize with keyboard
                            backgroundColor:
                                Colors.transparent, // Make modal transparent
                            builder: (BuildContext context) {
                              double keyboardHeight = MediaQuery.of(context)
                                  .viewInsets
                                  .bottom; // Detect keyboard height
                              return SizedBox(
                                height: keyboardHeight > 0
                                    ? MediaQuery.of(context).size.height * 0.9
                                    : MediaQuery.of(context).size.height *
                                        0.6, // Increase height when keyboard appears
                                child: Stack(
                                  children: [
                                    // Blur effect
                                    BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 5, sigmaY: 5),
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
                          'Sign Up'.tr(),
                          style: AppTheme.smallTitle(context,
                              color: AppTheme.dark),
                        ),
                      ),
                      SizedBox(height: 15),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(36.0),
                          ),
                          minimumSize: Size(0.70 * screenWidth, 55.0),
                          side: BorderSide(
                            color:
                                AppTheme.themedBgColor(context), // สีของเส้นขอบ
                            width: 2.0, // ความหนาของเส้นขอบ
                          ),
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            isScrollControlled: true,
                            context:
                                context, // Allow modal to resize with keyboard
                            backgroundColor:
                                Colors.transparent, // Make modal transparent
                            builder: (BuildContext context) {
                              double keyboardHeight = MediaQuery.of(context)
                                  .viewInsets
                                  .bottom; // Detect keyboard height
                              return SizedBox(
                                height: keyboardHeight > 0
                                    ? MediaQuery.of(context).size.height * 0.85
                                    : MediaQuery.of(context).size.height *
                                        0.55, // Increase height when keyboard appears
                                child: Stack(
                                  children: [
                                    // Blur effect
                                    BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 5, sigmaY: 5),
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
                          'Log In'.tr(),
                          style: AppTheme.smallTitle(context,
                              color: AppTheme.light),
                        ),
                      ),
                      SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          showModalBottomSheet(
                            isScrollControlled: true,
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (BuildContext context) {
                              double keyboardHeight =
                                  MediaQuery.of(context).viewInsets.bottom;
                              return SizedBox(
                                height: keyboardHeight > 0
                                    ? MediaQuery.of(context).size.height * 0.9
                                    : MediaQuery.of(context).size.height * 0.6,
                                child: Stack(
                                  children: [
                                    BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 5, sigmaY: 5),
                                      child: Container(
                                        color: Colors.transparent,
                                      ),
                                    ),
                                    Positioned(
                                      child: TermOfServicePage(),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: Text(
                          'Term of Service'.tr(),
                          style: AppTheme.smallTitle(context,
                              color: AppTheme.dark),
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
