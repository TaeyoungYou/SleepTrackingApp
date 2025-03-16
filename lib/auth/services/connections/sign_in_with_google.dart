
import '../authentication_with_wake_guard.dart';

class SignInWithGoogle extends AuthenticationWithWakeGuard {
  @override
  SocialConnection get connection => SocialConnection.google;
}