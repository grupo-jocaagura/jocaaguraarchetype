import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

class HomeSessionPage extends StatelessWidget {
  const HomeSessionPage({super.key});
  @override
  Widget build(BuildContext context) {
    final AppManager app = context.appManager;
    return Scaffold(
      appBar: AppBar(title: const Text('Home (Session)')),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: const Text('Counter'),
              onTap: () => app.pushOnce('/counter'),
            ),
            ListTile(
              title: const Text('Settings'),
              onTap: () => app.pushOnce('/settings'),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You are logged in.'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => app.pushOnce('/counter'),
              child: const Text('Open Counter'),
            ),
          ],
        ),
      ),
    );
  }
}
