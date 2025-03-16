import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import './screen/profile_page.dart';
import './auth/services/authentication_with_wake_guard.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Material App',
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

  void navigateToUserProfile(Credentials credentials) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(credentials: credentials),
      ),
    );
  }

  Future<void> _handleUniversalLogin() async {
    setState(() => _isLoading = true);
    try {
      final authService = AuthenticationWithWakeGuard();
      final credentials = await authService.signIn();
      navigateToUserProfile(credentials);
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
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Align(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _handleUniversalLogin,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Sign In / Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}