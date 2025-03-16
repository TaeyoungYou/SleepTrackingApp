import 'dart:ui';
import 'package:auth0_flutter/auth0_flutter.dart'; // Added for Auth0
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart'; // Added for kDebugMode
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:unknow/auth/services/authentication_with_wake_guard.dart'; // Added for auth service
import 'package:unknow/config/colors.dart';
import 'package:unknow/screen/profile_page.dart'; // Added for navigation after login

import 'Home.dart';

class Login extends StatefulWidget {
  final CameraDescription camera;
  const Login({super.key, required this.camera});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInFirst;
  late Animation<double> _fadeInSecond;
  late AnimationController _overlayController;
  late Animation<double> _overlayFade;
  bool _isLoading = false; // Added for loading state

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    );

    _fadeInFirst = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    _fadeInSecond = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.4, 1, curve: Curves.easeIn),
    );

    Future.delayed(Duration(seconds: 2), () {
      _controller.forward();
    });

    _overlayController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _overlayFade = CurvedAnimation(
      parent: _overlayController,
      curve: Curves.easeIn,
    );

    Future.delayed(Duration(seconds: 7), () {
      _overlayController.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _overlayController.dispose(); // Added to dispose overlayController
    super.dispose();
  }

  // Added method for Universal Login
  Future<void> _handleUniversalLogin() async {
    setState(() => _isLoading = true);
    try {
      final authService = AuthenticationWithWakeGuard();
      final credentials = await authService.signIn();
      // Navigate to Home after successful login
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondaryAnimation) => Home(camera: widget.camera),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Login failed: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication failed')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UI_White,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top: -400,
                          child: Transform.rotate(
                            angle: 18.3,
                            child: Container(
                              width: 1000,
                              height: 800,
                              decoration: BoxDecoration(
                                color: UI_Black,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                        Lottie.asset(
                          'assets/emoji/jam.json',
                          width: 500,
                          height: 500,
                          repeat: false,
                          animate: true,
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    FadeTransition(
                      opacity: _fadeInFirst,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Wake Guard",
                          style: TextStyle(
                            color: UI_Black,
                            fontWeight: FontWeight.bold,
                            fontSize: 40,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    FadeTransition(
                      opacity: _fadeInSecond,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Your AI Powered Guardian\n Against Drowsy Driving",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: UI_Black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            FadeTransition(
              opacity: _overlayFade,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                    child: Center(
                      child: LoginButton(
                        onPressed: _isLoading ? null : _handleUniversalLogin, // Updated to handle login
                        text: _isLoading ? '' : 'START', // Show empty text when loading
                        normalColor: UI_White,
                        pressedColor: background.withOpacity(0.1),
                        textStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: UI_Black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginButton extends StatefulWidget {
  final VoidCallback? onPressed; // Made nullable to handle disabled state
  final String text;
  final Color normalColor;
  final Color pressedColor;
  final TextStyle textStyle;

  const LoginButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.normalColor,
    required this.pressedColor,
    required this.textStyle,
  });

  @override
  State<LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: 200,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _isPressed ? widget.pressedColor : widget.normalColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: widget.text.isEmpty
            ? CircularProgressIndicator(color: UI_Black) // Show loading indicator
            : Text(widget.text, style: widget.textStyle),
      ),
    );
  }
}