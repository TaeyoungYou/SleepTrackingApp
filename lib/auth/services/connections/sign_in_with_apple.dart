import '../authentication_with_wake_guard.dart';

class SignInWithApple extends AuthenticationWithWakeGuard {
  @override
  SocialConnection get connection => SocialConnection.apple;
}