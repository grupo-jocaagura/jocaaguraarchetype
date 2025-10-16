import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Subclase mínima para pruebas.
class _FakeService extends ServiceThemeReact {
  void push(Map<String, dynamic> json) => updateTheme(json);
}

void main() {
  group('ServiceThemeReact • estado inicial y lectura', () {
    test(
        'Given new service When created Then themeStateJson starts at ThemeState.defaults.toJson()',
        () {
      final _FakeService s = _FakeService();
      expect(s.themeStateJson, ThemeState.defaults.toJson());
      s.dispose();
    });
  });

  group('ServiceThemeReact • updateTheme (igualdad por identidad)', () {
    test('Given same Map instance When updateTheme Then does NOT emit',
        () async {
      final _FakeService s = _FakeService();
      final List<Map<String, dynamic>> events = <Map<String, dynamic>>[];
      final StreamSubscription<Map<String, dynamic>> sub =
          s.themeStream.listen(events.add);

      // Primer update con la misma referencia del valor actual
      final Map<String, dynamic> sameRef = s.themeStateJson;
      await Future<void>.delayed(const Duration(milliseconds: 1));
      s.updateTheme(sameRef);

      // Espera corta para capturar posibles emisiones
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(
        events.length,
        0,
        reason: 'No debería emitir al usar la misma instancia',
      );

      await sub.cancel();
      s.dispose();
    });

    test(
        'Given different Map instance (deep-equal) When updateTheme Then emits once',
        () async {
      final _FakeService s = _FakeService();
      final List<Map<String, dynamic>> events = <Map<String, dynamic>>[];
      final StreamSubscription<Map<String, dynamic>> sub =
          s.themeStream.listen(events.add);

      // Clonar el JSON actual (contenido igual, instancia diferente)
      final Map<String, dynamic> clone =
          Map<String, dynamic>.from(s.themeStateJson);
      s.updateTheme(clone);

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(events.length, 1);
      expect(events.first, clone);

      await sub.cancel();
      s.dispose();
    });
  });

  group(
      'ServiceThemeReact • funciones de procesamiento (delegadas a BlocGeneral)',
      () {
    test(
        'Given a processor When added Then it can mutate the outgoing map before listeners see it',
        () async {
      final _FakeService s = _FakeService();
      final List<Map<String, dynamic>> events = <Map<String, dynamic>>[];
      final StreamSubscription<Map<String, dynamic>> sub =
          s.themeStream.listen(events.add);

      // Registrar una función que marque un flag en el JSON emitido
      s.addFunctionToProcessValueOnStream('mark', (Map<String, dynamic> v) {
        v['__mark'] = true;
      });

      // Disparar una actualización con una NUEVA instancia
      final Map<String, dynamic> next =
          Map<String, dynamic>.from(s.themeStateJson)..['preset'] = 'brand';
      s.updateTheme(next);

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(events, isNotEmpty);
      expect(events.last['__mark'], true);

      await sub.cancel();
      s.dispose();
    });

    test('Given a processor added Then deleting by key stops future mutations',
        () async {
      final _FakeService s = _FakeService();
      final List<Map<String, dynamic>> events = <Map<String, dynamic>>[];
      final StreamSubscription<Map<String, dynamic>> sub =
          s.themeStream.listen(events.add);

      s.addFunctionToProcessValueOnStream('mark', (Map<String, dynamic> v) {
        v['__mark'] = true;
      });

      // Primera emisión: debe venir marcado
      final Map<String, dynamic> a = Map<String, dynamic>.from(s.themeStateJson)
        ..['preset'] = 'p1';
      s.updateTheme(a);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(events.last['__mark'], true);

      // Eliminar por key (el parámetro function es ignorado por la implementación actual)
      s.deleteFunctionToProcessValueOnStream(
        'mark',
      );

      // Segunda emisión: ya no debe venir marcado
      final Map<String, dynamic> b = Map<String, dynamic>.from(events.last)
        ..['preset'] = 'p2';
      s.updateTheme(b);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(events.last['__mark'], isNull);

      await sub.cancel();
      s.dispose();
    });
  });

  group('ServiceThemeReact • dispose', () {
    test(
        'Given disposed service When updating Then should not throw and should not notify listeners',
        () async {
      final _FakeService s = _FakeService();
      final List<Map<String, dynamic>> events = <Map<String, dynamic>>[];
      final StreamSubscription<Map<String, dynamic>> sub =
          s.themeStream.listen(events.add);

      await sub.cancel();
      s.dispose();

      // No debería lanzar; tampoco hay listeners activos ya.
      s.updateTheme(
        Map<String, dynamic>.from(s.themeStateJson)
          ..['preset'] = 'afterDispose',
      );

      // Sin listeners, validamos simplemente que no hay excepciones. (Éxito si llega aquí)
      expect(true, isTrue);
    });
  });
}
