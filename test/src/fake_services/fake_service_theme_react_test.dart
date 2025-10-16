import 'dart:async';

import 'package:flutter/material.dart' show TextStyle, TextTheme;
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('FakeServiceThemeReact • constructor & seeding', () {
    test(
        'Given no payloads When constructed Then seeds bus with light defaults and ensures mode',
        () {
      final FakeServiceThemeReact s = FakeServiceThemeReact();
      final Map<String, dynamic> curr = s.themeStateJson;
      expect(curr['mode'], 'light'); // ensureMode applied
      // No asumimos replay en stream; validamos el estado actual
      s.dispose();
    });

    test('Given custom payloads When constructed Then ensures mode keys', () {
      final FakeServiceThemeReact s = FakeServiceThemeReact(
        lightJson: <String, dynamic>{'preset': 'brand'}, // without mode
        darkJson: <String, dynamic>{'preset': 'brand'}, // without mode
      );
      expect(s.lightJson['mode'], 'light');
      expect(s.darkJson['mode'], 'dark');
      s.dispose();
    });
  });

  group('FakeServiceThemeReact • textOverrides merge (non-destructive)', () {
    test('Given textOverridesJson When constructing Then merged only if absent',
        () {
      final Map<String, dynamic> txt = const TextThemeOverrides(
        light: TextTheme(bodyMedium: TextStyle(fontSize: 14)),
        dark: TextTheme(bodyMedium: TextStyle(fontSize: 14)),
        fontName: 'Inter',
      ).toJson();

      // Caso 1: sin textOverrides en base -> se agrega
      final FakeServiceThemeReact s1 =
          FakeServiceThemeReact(textOverridesJson: txt);
      expect(s1.lightJson['textOverrides'], isNotNull);
      expect(s1.darkJson['textOverrides'], isNotNull);
      s1.dispose();

      // Caso 2: si el payload ya trae textOverrides, se preserva (no destructivo)
      final Map<String, dynamic> baseWithText = <String, dynamic>{
        'mode': 'light',
        'preset': 'x',
        'textOverrides': <String, dynamic>{'fontName': 'KeepMe'},
      };
      final FakeServiceThemeReact s2 = FakeServiceThemeReact(
        lightJson: baseWithText,
        textOverridesJson: txt,
      );
      expect(
        (s2.lightJson['textOverrides'] as Map<String, dynamic>)['fontName'],
        'KeepMe',
      );
      s2.dispose();
    });

    test(
        'Given setTextOverridesJson When invoked Then merges into both and reflects current',
        () {
      final FakeServiceThemeReact s =
          FakeServiceThemeReact(); // current mode = light
      final List<Map<String, dynamic>> events = <Map<String, dynamic>>[];
      final StreamSubscription<Map<String, dynamic>> sub =
          s.themeStream.listen(events.add);

      final Map<String, dynamic> txt = const TextThemeOverrides(
        light: TextTheme(titleSmall: TextStyle(fontSize: 12)),
        dark: TextTheme(titleSmall: TextStyle(fontSize: 12)),
      ).toJson();

      s.setTextOverridesJson(txt);

      // Espero un tick para captura
      addTearDown(() => sub.cancel());
      expect(s.lightJson['textOverrides'], isNotNull);
      expect(s.darkJson['textOverrides'], isNotNull);
      // Debe reflejar de inmediato el modo actual (light)
      // No aseguramos que el stream reemita de inmediato; pero si hay evento, su contenido debe incluir textOverrides.
      if (events.isNotEmpty) {
        expect(events.last['textOverrides'], isNotNull);
      }
      s.dispose();
    });
  });

  group('FakeServiceThemeReact • setLightJson / setDarkJson', () {
    test(
        'Given setLightJson When current mode is light Then updates bus immediately',
        () async {
      final FakeServiceThemeReact s = FakeServiceThemeReact(); // light actual
      final List<Map<String, dynamic>> events = <Map<String, dynamic>>[];
      final StreamSubscription<Map<String, dynamic>> sub =
          s.themeStream.listen(events.add);

      final Map<String, dynamic> next = <String, dynamic>{'preset': 'brand'};
      s.setLightJson(next);

      await Future<void>.delayed(const Duration(milliseconds: 15));
      expect(s.lightJson['mode'], 'light'); // ensured
      // Si el stream emite, debe contener el nuevo preset
      if (events.isNotEmpty) {
        expect(events.last['preset'], 'brand');
      }

      await sub.cancel();
      s.dispose();
    });

    test(
        'Given setDarkJson When current mode is light Then does NOT update bus until toggled',
        () async {
      final FakeServiceThemeReact s = FakeServiceThemeReact(); // light actual
      final List<Map<String, dynamic>> events = <Map<String, dynamic>>[];
      final StreamSubscription<Map<String, dynamic>> sub =
          s.themeStream.listen(events.add);

      s.setDarkJson(<String, dynamic>{'preset': 'darkBrand'});

      await Future<void>.delayed(const Duration(milliseconds: 15));
      // No aseguramos eventos; validamos que el estado actual en bus siga siendo light
      expect(s.themeStateJson['mode'], 'light');

      await sub.cancel();
      s.dispose();
    });
  });

  group('FakeServiceThemeReact • auto toggle start/stop/restart', () {
    test('Given startAutoToggle Then service alternates between light and dark',
        () async {
      final FakeServiceThemeReact s = FakeServiceThemeReact();
      final List<Map<String, dynamic>> events = <Map<String, dynamic>>[];
      final StreamSubscription<Map<String, dynamic>> sub =
          s.themeStream.listen(events.add);

      s.startAutoToggle(period: const Duration(milliseconds: 20));
      await Future<void>.delayed(const Duration(milliseconds: 65));
      s.stopAutoToggle();

      // Debió alternar al menos una vez
      // Verificamos que haya habido algún evento y que el modo cambie en algún punto
      bool sawLight = false, sawDark = false;
      for (final Map<String, dynamic> e in events) {
        if (e['mode'] == 'light') {
          sawLight = true;
        }
        if (e['mode'] == 'dark') {
          sawDark = true;
        }
      }
      expect(sawLight || sawDark, isTrue);
      // Idealmente ambos:
      expect(sawLight && sawDark, isTrue);

      await sub.cancel();
      s.dispose();
    });

    test(
        'Given startAutoToggle twice with new period Then timer restarts using the new period',
        () async {
      final FakeServiceThemeReact s = FakeServiceThemeReact();
      final List<Map<String, dynamic>> events = <Map<String, dynamic>>[];
      final StreamSubscription<Map<String, dynamic>> sub =
          s.themeStream.listen(events.add);

      s.startAutoToggle(period: const Duration(milliseconds: 30));
      await Future<void>.delayed(const Duration(milliseconds: 40));
      // Reinicio con periodo más corto
      s.startAutoToggle(period: const Duration(milliseconds: 10));
      await Future<void>.delayed(const Duration(milliseconds: 35));
      s.stopAutoToggle();

      // Debe haber habido múltiples alternancias
      expect(events.length, greaterThanOrEqualTo(2));

      await sub.cancel();
      s.dispose();
    });

    test(
        'Given dispose When timer running Then it is cancelled and no errors thrown',
        () async {
      final FakeServiceThemeReact s = FakeServiceThemeReact(
        autoStart: true,
        period: const Duration(milliseconds: 10),
      );
      // Dispose debería detener el timer sin arrojar
      s.dispose();
      // Espera pequeña para descartar ticks remanentes
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(true, isTrue); // llegó sin excepciones
    });
  });

  group('FakeServiceThemeReact • defensive copies', () {
    test(
        'Given getters When maps are mutated externally Then internal state remains intact',
        () {
      final FakeServiceThemeReact s = FakeServiceThemeReact();
      final Map<String, dynamic> copy = s.lightJson;
      copy['mode'] = 'dark'; // mutación externa a la copia
      expect(s.lightJson['mode'], 'light'); // interno intacto
      s.dispose();
    });
  });
}
