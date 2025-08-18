// example/lib/wiring/onboarding_demo_bootstrap.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

class OnboardingDemoBootstrap extends StatefulWidget {
  const OnboardingDemoBootstrap({
    required this.child,
    required this.blocOnboarding,
    super.key,
  });
  final Widget child;
  final BlocOnboarding blocOnboarding;
  @override
  State<OnboardingDemoBootstrap> createState() =>
      _OnboardingDemoBootstrapState();
}

class _OnboardingDemoBootstrapState extends State<OnboardingDemoBootstrap> {
  StreamSubscription<OnboardingState>? _sub;

  @override
  void initState() {
    super.initState();

    // 1) Configura UN paso con mensaje y auto-avanze en 3s
    widget.blocOnboarding.configure(<OnboardingStep>[
      const OnboardingStep(
        title: 'Bienvenido a la demo',
        autoAdvanceAfter: Duration(seconds: 3),
        // onEnter opcional; devuelve éxito por defecto:
        // onEnter: () async => Right<ErrorItem, Unit>(Unit.value),
      ),
    ]);

    // (Opcional) Si tu router necesita ir explícitamente a la pantalla de Onboarding:
    // app.navigator.pageManager.replaceWith('/onboarding');

    // 2) Al completar → navega a IndexApp
    _sub = widget.blocOnboarding.stateStream.listen((OnboardingState s) {
      if (s.status == OnboardingStatus.completed) {
        // Usa tu helper real de navegación. Ejemplos:
        // app.navigator.pageManager.replaceWith('/index');
        // app.navigator.replaceAll(<String>[IndexAppPage.route]);
        // app.navigator.toIndex();
      }
    });

    // 3) ¡Arranca!
    widget.blocOnboarding.start();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
