import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../support/example_services.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  String _status = 'Starting…';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    final AppManager app = context.appManager;

    // Paso 1: conectividad
    setState(() => _status = 'Checking connectivity…');
    final bool online = await ExampleConnectivity.instance.checkNow();
    if (!online) {
      app.notify('You are offline. Some features may be limited.');
    }

    // Paso 2: sesión
    setState(() => _status = 'Checking session…');
    final bool logged = await ExampleAuth.instance.ensureInitializedAndCheck();

    // Navegar según resultado
    app.replaceTop(logged ? '/home-session' : '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(_status),
          ],
        ),
      ),
    );
  }
}
