import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';
import '../main2.dart';
import '../auth//services/authentication_with_wake_guard.dart';

class ProfilePage extends StatefulWidget {
  final Credentials credentials;

  const ProfilePage({super.key, required this.credentials});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfile get user => widget.credentials.user;
  String? get name => user.name;
  Uri? get photo => user.pictureUrl;

  void navigateToLoginPage() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: const SizedBox.shrink(),
      ),
      body: Align(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(photo.toString()),
              radius: 40,
            ),
            const SizedBox(height: 12),
            Text(
              name ?? 'No name',
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                AuthenticationWithWakeGuard authWithSocials =
                AuthenticationWithWakeGuard();

                await authWithSocials.signOut();
                navigateToLoginPage();
              },
              child: const Text('Sign out'),
            )
          ],
        ),
      ),
    );
  }
}