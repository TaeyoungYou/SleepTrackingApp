import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';

class MainView extends StatefulWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  Credentials? _credentials;
  late Auth0 auth0;

  @override
  void initState() {
    super.initState();
    auth0 = Auth0(
        'dev-dq35jgmk2wftplfm.us.auth0.com',  // Replace with your Auth0 domain
        'Dpv1brt1vS9MaJmHW1buVmuzXYr2Cjhs'   // Replace with your Client ID
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auth0 Login')),
      body: Center(
        child: _credentials == null
            ? ElevatedButton(
          onPressed: _login,
          child: const Text("Log in"),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Logged in as: ${_credentials!.user.name}"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logout,
              child: const Text("Log out"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    try {
      final credentials = await auth0.webAuthentication(
          scheme: "com.example.unknow" // Using custom scheme
      ).login(
          parameters: {
            "connection": "Username-Password-Authentication" // Forces Auth0 login page
          }
      );

      setState(() {
        _credentials = credentials;
      });
      print("Login successful: ${credentials.accessToken}");
    } catch (e) {
      print("Login failed: $e");
    }
  }




  Future<void> _logout() async {
    try {
      await auth0.webAuthentication().logout();
      setState(() {
        _credentials = null;
      });
    } catch (e) {
      print('Logout failed: $e');
    }
  }
}
