import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/foundation.dart';
import './authentication_service.dart';

// Keep this enum for potential future use
enum SocialConnection {
  apple('apple'),
  google('google-oauth2');

  final String getName;

  const SocialConnection(this.getName);
}

class AuthenticationWithWakeGuard extends AuthenticationService<Credentials> {
  SocialConnection? connection; // Nullable, kept for future use

  AuthenticationWithWakeGuard({this.connection});

  @override
  Future<Credentials> signIn() async {
    try {
      // Always use Universal Login (ignore connection for now)
      Credentials response = await auth0.webAuthentication(scheme: 'demo').login();

      if (kDebugMode) {
        print('Sign-in successful: ${response.accessToken}');
      }
      return response;
    } catch (e) {
      if (!kReleaseMode) {
        debugPrint('Universal Login failed: ${e.toString()}');
      }
      throw Exception('Authentication failed');
    }
  }

  @override
  Future<void> signOut() async {
    await auth0.webAuthentication(scheme: 'demo').logout();
  }
}