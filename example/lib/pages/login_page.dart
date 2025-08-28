import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../support/example_services.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) {
    final AppManager app = context.appManager;
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                ExampleAuth.instance.setLoggedIn(true);
                app.replaceTop('/home-session');
              },
              child: const Text('Simulate Login'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                ExampleAuth.instance.setLoggedIn(false);
                app.replaceTop('/home');
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
