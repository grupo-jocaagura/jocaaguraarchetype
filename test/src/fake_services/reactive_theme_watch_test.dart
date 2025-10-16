import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('Reactive flow · watch()', () {
    test('emite cambios cuando el Service hace flip (auto toggle)', () async {
      // Service con light/dark mínimos y flip rápido para el test
      final FakeServiceThemeReact service = FakeServiceThemeReact(
        lightJson: ThemeState.defaults.copyWith(mode: ThemeMode.light).toJson(),
        darkJson: ThemeState.defaults.copyWith(mode: ThemeMode.dark).toJson(),
        period: const Duration(milliseconds: 120),
      );
      final GatewayThemeReactImpl gateway =
          GatewayThemeReactImpl(service: service);
      final RepositoryThemeReactImpl repo =
          RepositoryThemeReactImpl(gateway: gateway);
      final WatchTheme watch = WatchTheme(repo);

      // Recolectamos dos emisiones con modos distintos
      final List<ThemeState> seen = <ThemeState>[];
      final StreamSubscription<Either<ErrorItem, ThemeState>> sub =
          watch().listen((Either<ErrorItem, ThemeState> either) {
        either.when((ErrorItem err) => fail('No debía fallar: $err'), seen.add);
      });

      // Arranca flip
      service.startAutoToggle();

      // Espera un par de periodos
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await sub.cancel();
      service.stopAutoToggle();
      service.dispose();

      // Debe haberse visto al menos un cambio de modo
      expect(seen.isNotEmpty, isTrue);
      final bool hasBoth =
          seen.any((ThemeState s) => s.mode == ThemeMode.light) &&
              seen.any((ThemeState s) => s.mode == ThemeMode.dark);
      expect(hasBoth, isTrue, reason: 'Debe alternar entre light y dark');
    });
  });

  group('TextThemeOverrides · roundtrip + normalización', () {
    test('roundtrip via gateway/write → repo/read preserva textOverrides',
        () async {
      final FakeServiceThemeReact service = FakeServiceThemeReact();
      final GatewayThemeReactImpl gateway =
          GatewayThemeReactImpl(service: service);
      final RepositoryThemeReactImpl repo =
          RepositoryThemeReactImpl(gateway: gateway);

      // Construimos un estado con textOverrides
      const TextThemeOverrides txt = TextThemeOverrides(
        light: TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 1.2),
        ),
        dark: TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 1.2),
        ),
      );
      final ThemeState s = ThemeState.defaults.copyWith(textOverrides: txt);

      // write → watch debe emitir normalizado y read → ThemeState restaurado
      final Either<ErrorItem, ThemeState> saved = await repo.save(s);
      saved.when(
        (ErrorItem e) => fail('save() no debía fallar: $e'),
        (ThemeState out) {
          expect(out.textOverrides, isNotNull);
          expect(out.textOverrides!.light!.bodyMedium!.fontFamily, 'Inter');
        },
      );

      final Either<ErrorItem, ThemeState> loaded = await repo.read();
      loaded.when(
        (ErrorItem e) => fail('read() no debía fallar: $e'),
        (ThemeState out) {
          expect(out.textOverrides, isNotNull);
          expect(
            out.textOverrides!.dark!.bodyMedium!.height,
            closeTo(1.2, 1e-9),
          );
        },
      );

      service.dispose();
    });

    test(
        'Gateway.write normaliza cuando textOverrides llega como objeto (toJson branch)',
        () async {
      final FakeServiceThemeReact service = FakeServiceThemeReact();
      final GatewayThemeReactImpl gateway =
          GatewayThemeReactImpl(service: service);
      final RepositoryThemeReactImpl repo =
          RepositoryThemeReactImpl(gateway: gateway);

      // Forzamos el branch: pasamos un objeto TextThemeOverrides en el JSON (no Map)
      final Map<String, dynamic> raw = <String, dynamic>{
        'mode': 'light',
        'seed': 0xFF445566,
        'useM3': true,
        'textScale': 1.0,
        'preset': 'brand',
        'textOverrides': const TextThemeOverrides(
          light: TextTheme(titleLarge: TextStyle(fontWeight: FontWeight.w600)),
          dark: TextTheme(titleLarge: TextStyle(fontWeight: FontWeight.w700)),
        ),
      };

      final Either<ErrorItem, Map<String, dynamic>> gw =
          await gateway.write(raw);
      gw.when(
        (ErrorItem e) => fail('gateway.write() falló: $e'),
        (Map<String, dynamic> json) {
          // Debe haber sido convertido a Map (JSON estable)
          expect(json['textOverrides'], isA<Map<String, dynamic>>());
          final TextThemeOverrides? restored = TextThemeOverrides.fromJson(
            json['textOverrides'] as Map<String, dynamic>,
          );
          expect(restored, isNotNull);
          expect(restored!.dark!.titleLarge!.fontWeight, FontWeight.w700);
        },
      );

      // A través del repo/read también debe llegar bien
      final Either<ErrorItem, ThemeState> state = await repo.read();
      state.when(
        (ErrorItem e) => fail('repo.read() falló: $e'),
        (ThemeState s) => expect(
          s.textOverrides!.light!.titleLarge!.fontWeight,
          FontWeight.w600,
        ),
      );

      service.dispose();
    });
  });
}
