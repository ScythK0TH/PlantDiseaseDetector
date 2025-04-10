import 'dart:ui';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:project_pdd/login.dart';
import 'package:bcrypt/bcrypt.dart';
import 'constant.dart';

class RegisApp extends StatefulWidget {
  const RegisApp({super.key});

  @override
  State<RegisApp> createState() => _RegisAppState();
}

class _RegisAppState extends State<RegisApp> {
  final List<String> textSequence = [
    "Register Today!",
    "Check Disease",
    "For your plant"
  ];
  bool _isObscure1 = true;
  bool _isObscure2 = true;
  int index = 0;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isRegisterEnabled = false;

  void _changeText() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          index = (index + 1) % textSequence.length;
        });
      }
    });
  }

  void _validateForm() {
    setState(() {
      _isRegisterEnabled = _passwordController.text.isNotEmpty &&
          _passwordController.text == _confirmPasswordController.text &&
          _emailController.text.isNotEmpty;
    });
  }

  Future<void> _registerUser() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

      final db = await mongo.Db.create(MONGO_URL);
      await db.open();

      final collection = db.collection('users');
      await collection.insert({
        'username': email,
        'email': email,
        'password': hashedPassword,
      });

      final result = await collection.find({'email': email}).toList();

      await db.close();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful!')),
      );

      // Navigate to login page
      Navigator.pop(context);
      showFirstModal(context);
    } catch (e) {
      print('Error: $e');
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
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
                        key: ValueKey<int>(index), // Forces rebuild
                        child: AnimatedTextKit(
                          animatedTexts: [
                            TypewriterAnimatedText(
                              textSequence[index],
                              textStyle: TextStyle(
                                  color: Color(0xFF464646), fontSize: 35.0),
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
                      "Create your account",
                      style:
                          TextStyle(color: Color(0xFF464646), fontSize: 21.5),
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
                                  color: Color(0xFF464646), width: 2),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50.0))),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Enter your email",
                          hintStyle: TextStyle(color: const Color(0xFF464646)),
                        ),
                        onChanged: (_) => _validateForm(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _isObscure1,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Color(0xFF464646), width: 2),
                            borderRadius:
                                BorderRadius.all(Radius.circular(50.0)),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Enter your password",
                          hintStyle: TextStyle(color: Color(0xFF464646)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscure1
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscure1 = !_isObscure1;
                              });
                            },
                          ),
                        ),
                        onChanged: (_) => _validateForm(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _isObscure2,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Color(0xFF464646), width: 2),
                            borderRadius:
                                BorderRadius.all(Radius.circular(50.0)),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Confirm your password",
                          hintStyle: TextStyle(color: Color(0xFF464646)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscure2
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscure2 = !_isObscure2;
                              });
                            },
                          ),
                        ),
                        onChanged: (_) => _validateForm(),
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
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isRegisterEnabled
                            ? Color(0xFF464646)
                            : Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        minimumSize: Size(0.50 * screenWidth, 55.0),
                      ),
                      onPressed: _isRegisterEnabled ? _registerUser : null,
                      child: Container(
                        alignment: Alignment.center,
                        width: 100,
                        child: Text("Register",
                            style: TextStyle(
                                fontSize: 15.0,
                                color: Color.fromARGB(255, 255, 255, 255))),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account?",
                            style: TextStyle(color: Color(0xFF464646))),
                        Container(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            child: Text("Login now",
                                style: TextStyle(color: Color(0xFF27AC3C))),
                            onPressed: () {
                              Navigator.pop(context);
                              showFirstModal(context);
                            },
                          ),
                        ),
                      ],
                    ),
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

void showFirstModal(BuildContext context) {
  showModalBottomSheet(
    isScrollControlled: true,
    context: context, // Allow modal to resize with keyboard
    backgroundColor: Colors.transparent, // Make modal transparent
    builder: (BuildContext context) {
      double keyboardHeight =
          MediaQuery.of(context).viewInsets.bottom; // Detect keyboard height
      return SizedBox(
        height: keyboardHeight > 0
            ? MediaQuery.of(context).size.height * 0.85
            : MediaQuery.of(context).size.height *
                0.55, // Increase height when keyboard appears
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
}
