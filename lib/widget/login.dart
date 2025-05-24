import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:bcrypt/bcrypt.dart';
import 'package:project_pdd/home.dart';
import 'package:project_pdd/services/database.dart';
import 'package:project_pdd/style.dart';
import 'package:project_pdd/widget/register.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginApp extends StatefulWidget {
  const LoginApp({super.key});

  @override
  LoginAppState createState() => LoginAppState();
}

class LoginAppState extends State<LoginApp> {
  bool _isObscure = true;
  String? _errorMessage;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final List<String> textSequence = [
    "Welcome to our app!!".tr(),
    "Let's get started!!".tr()
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

  // Call this after successful login
  Future<void> saveLoginState(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  Future<void> _loginUser() async {
    setState(() {
      _errorMessage = null;
    });

    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = "Email and password cannot be empty";
      });
      return;
    }

    try {
      print('Connecting to MongoDB...');
      final db = MongoService();
      print('Connected to MongoDB.');

      final collection = db.userCollection;
      print('Finding user...');
      final user = await collection!.findOne({'email': email});

      if (user != null) {
        final hashedPassword = user['password'];
        if (BCrypt.checkpw(password, hashedPassword)) {
          print('Login successful!');
          await saveLoginState(user['_id'].toHexString());

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  HomePage(userId: user['_id'].toHexString()),
            ),
          );
        } else {
          print('Invalid password.');
          setState(() {
            _errorMessage = "Invalid password";
          });
        }
      } else {
        print('User not found.');
        setState(() {
          _errorMessage = "Invalid email or User not found";
        });
      }

    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? primaryColor
            : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(36.0)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: keyboardHeight > 0
              ? MediaQuery.of(context).size.height * 0.35
              : MediaQuery.of(context).size.height * 0.05,
        ),
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 500),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: Container(
                        key: ValueKey<int>(index),
                        child: AnimatedTextKit(
                          animatedTexts: [
                            TypewriterAnimatedText(
                              textSequence[index],
                              textStyle: subTitleTextStyleDark(context,
                                  fontWeight: FontWeight.bold),
                              speed: Duration(milliseconds: 150),
                              cursor: '|',
                            ),
                          ],
                          isRepeatingAnimation: false,
                          onFinished: _changeText,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Sign into your account".tr(),
                      style: descTextStyleDark(context,
                          fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : primaryColor,
                                  width: 2),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(36.0))),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Enter your email".tr(),
                          hintStyle: subDescTextStyleDark(context,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _isObscure,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : primaryColor,
                                width: 2),
                            borderRadius:
                                BorderRadius.all(Radius.circular(36.0)),
                          ),
                          filled: true,
                          fillColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? primaryColor
                                  : Colors.white,
                          hintText: "Enter your password".tr(),
                          hintStyle: subDescTextStyleDark(context,
                              fontWeight: FontWeight.normal),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscure = !_isObscure;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          _errorMessage!.tr(),
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Column(
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(36.0),
                        ),
                        minimumSize: Size(0.50 * screenWidth, 55.0),
                      ),
                      onPressed: _loginUser,
                      child: Container(
                          alignment: Alignment.center,
                          width: 100,
                          child: Text("Login".tr(),
                              style: TextStyle(
                                  fontSize: 15.0, color: Colors.white)))),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account?".tr(),
                          style: subDescTextStyleDark(context,
                              fontWeight: FontWeight.normal)),
                      Container(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            child: Text("Register now".tr(),
                                style: subSuccessTextStyle(
                                    fontWeight: FontWeight.bold)),
                            onPressed: () {
                              Navigator.pop(context); // Close current modal
                              showSecondModal(
                                  context); // Wait before opening the next modal
                            },
                          )),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

void showSecondModal(BuildContext context) {
  showModalBottomSheet(
    isScrollControlled: true,
    context: context, // Allow modal to resize with keyboard
    backgroundColor: Colors.transparent, // Make modal transparent
    builder: (BuildContext context) {
      double keyboardHeight =
          MediaQuery.of(context).viewInsets.bottom; // Detect keyboard height
      return SizedBox(
        height: keyboardHeight > 0
            ? MediaQuery.of(context).size.height * 0.9
            : MediaQuery.of(context).size.height *
                0.6, // Increase height when keyboard appears
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
}
