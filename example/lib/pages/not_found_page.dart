import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});
  @override
  Widget build(BuildContext context) {
    final AppManager app = context.appManager;
    return Scaffold(
      appBar: AppBar(title: const Text('Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('404 — Page not found'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => app.goTo('/home'),
              icon: const Icon(Icons.home),
              label: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
