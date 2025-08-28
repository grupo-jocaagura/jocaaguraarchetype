import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

class HomeGuestPage extends StatelessWidget {
  const HomeGuestPage({super.key});
  @override
  Widget build(BuildContext context) {
    final AppManager app = context.appManager;
    return Scaffold(
      appBar: AppBar(title: const Text('Home (Guest)')),
      drawer: _ExampleDrawer(app: app),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Welcome! Please sign in to access Counter.'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => app.goTo('/login'),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExampleDrawer extends StatelessWidget {
  const _ExampleDrawer({required this.app});
  final AppManager app;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('Settings'),
            onTap: () => app.pushOnce('/settings'),
          ),
        ],
      ),
    );
  }
}
