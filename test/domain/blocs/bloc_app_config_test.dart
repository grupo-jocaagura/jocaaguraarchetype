import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Registry mínimo para usar AppConfig.dev
PageRegistry _dummyRegistry() => PageRegistry(<String, PageWidgetBuilder>{});

/// Construye un AppConfig.dev listo para pruebas.
AppConfig _makeDev({List<OnboardingStep> steps = const <OnboardingStep>[]}) {
  return AppConfig.dev(registry: _dummyRegistry(), onboardingSteps: steps);
}

void main() {
  group('BlocAppConfig', () {
    test('estado inicial coincide con el AppConfig provisto', () async {
      final AppConfig initial = _makeDev();
      final BlocAppConfig bloc = BlocAppConfig(initial: initial);

      expect(bloc.state, same(initial));

      // Limpieza
      await initial.dispose();
      bloc.dispose();
    });

    test('stream emite el nuevo AppConfig en switchTo()', () async {
      final AppConfig initial = _makeDev();
      final AppConfig next = _makeDev(
        steps: <OnboardingStep>[const OnboardingStep(title: 'step')],
      );

      final BlocAppConfig bloc = BlocAppConfig(initial: initial);

      // Esperamos que el stream emita exactamente "next" luego del switch.
      final Future<AppConfig> f = bloc.stream.first;
      bloc.switchTo(next);
      final AppConfig emitted = await f;

      expect(emitted, same(next));
      expect(bloc.state, same(next));

      // Limpieza
      await initial.dispose();
      await next.dispose();
      bloc.dispose();
    });

    test('stream (broadcast) entrega a múltiples suscriptores', () async {
      final AppConfig initial = _makeDev();
      final AppConfig next = _makeDev();

      final BlocAppConfig bloc = BlocAppConfig(initial: initial);

      AppConfig? a;
      AppConfig? b;
      final StreamSubscription<AppConfig> subA =
          bloc.stream.listen((AppConfig c) => a = c);
      final StreamSubscription<AppConfig> subB =
          bloc.stream.listen((AppConfig c) => b = c);

      bloc.switchTo(next);

      // Espera breve para procesar microtareas.
      await Future<void>.delayed(const Duration(milliseconds: 1));

      expect(a, same(next));
      expect(b, same(next));
      expect(bloc.state, same(next));

      await subA.cancel();
      await subB.cancel();

      await initial.dispose();
      await next.dispose();
      bloc.dispose();
    });

    test(
        'switchTo(resetStack: true) también emite (la app shell decide aplicar el reset)',
        () async {
      final AppConfig initial = _makeDev();
      final AppConfig next = _makeDev();

      final BlocAppConfig bloc = BlocAppConfig(initial: initial);

      final Future<AppConfig> f = bloc.stream.first;
      bloc.switchTo(next, resetStack: true);
      final AppConfig emitted = await f;

      expect(emitted, same(next));
      expect(bloc.state, same(next));

      await initial.dispose();
      await next.dispose();
      bloc.dispose();
    });

    test('dispose() cierra stream; luego de dispose, switchTo lanza StateError',
        () async {
      final AppConfig initial = _makeDev();
      final AppConfig next = _makeDev();

      final BlocAppConfig bloc = BlocAppConfig(initial: initial);
      bloc.dispose();

      // No se puede volver a emitir tras cerrar el StreamController.
      expect(() => bloc.switchTo(next), throwsStateError);

      await initial.dispose();
      await next.dispose();
    });
  });
}
