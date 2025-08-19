import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('GatewayThemeImpl', () {
    test('read() sin documento => Left(ERR_NOT_FOUND)', () async {
      final GatewayThemeImpl gateway = GatewayThemeImpl(
        themeService: const FakeServiceJocaaguraArchetypeTheme(),
      );

      final Either<ErrorItem, Map<String, dynamic>> result =
          await gateway.read();

      result.when(
        (ErrorItem err) {
          expect(err.code, 'ERR_NOT_FOUND');
          expect(err.meta['location'], 'GatewayThemeImpl.read');
        },
        (_) => fail('Esperábamos Left(ERR_NOT_FOUND)'),
      );
    });

    test('write() + read() => payload normalizado + smoke test pasa', () async {
      final GatewayThemeImpl gateway = GatewayThemeImpl(
        themeService: const FakeServiceJocaaguraArchetypeTheme(),
      );

      // Payload con valores "sucios" para verificar normalización
      final Map<String, dynamic> writePayload = <String, dynamic>{
        'mode': 'weird', // se normaliza a 'system'
        'seed': 'not-an-int', // se normaliza a default 0xFF6750A4
        // 'useM3' ausente => true
        'textScale': 5.0, // se clampa a 1.6
        // 'preset' ausente => 'brand'
      };

      final Either<ErrorItem, Map<String, dynamic>> w =
          await gateway.write(writePayload);
      w.when(
        (_) => fail('write() no debe fallar'),
        (Map<String, dynamic> saved) {
          expect(saved['mode'], 'system');
          expect(saved['useM3'], true);
          expect(saved['textScale'], 1.6);
          expect(saved['preset'], 'brand');
          expect(saved['seed'], isA<int>());
        },
      );

      final Either<ErrorItem, Map<String, dynamic>> r = await gateway.read();
      r.when(
        (_) => fail('read() no debe fallar tras write'),
        (Map<String, dynamic> read) {
          expect(read['mode'], 'system');
          expect(read['useM3'], true);
          expect(read['textScale'], 1.6);
          expect(read['preset'], 'brand');
          expect(read['seed'], isA<int>());
          // Smoke test ocurre internamente; si fuera inválido habría lanzado y mapeado a Left.
        },
      );
    });

    test('write() con valores válidos se persiste y respeta valores', () async {
      final GatewayThemeImpl gateway = GatewayThemeImpl(
        themeService: const FakeServiceJocaaguraArchetypeTheme(),
      );

      final Map<String, dynamic> custom = <String, dynamic>{
        'mode': 'dark',
        'seed': const Color(0xFF123456).toARGB32(),
        'useM3': false,
        'textScale': 1.1,
        'preset': 'custom',
      };

      final Either<ErrorItem, Map<String, dynamic>> w =
          await gateway.write(custom);
      expect(w.isRight, true);

      final Either<ErrorItem, Map<String, dynamic>> r = await gateway.read();
      r.when(
        (_) => fail('read() no debe fallar'),
        (Map<String, dynamic> read) {
          expect(read['mode'], 'dark');
          expect(read['useM3'], false);
          expect(read['textScale'], 1.1);
          expect(read['preset'], 'custom');
          expect(read['seed'], const Color(0xFF123456).toARGB32());
        },
      );
    });
  });
}
