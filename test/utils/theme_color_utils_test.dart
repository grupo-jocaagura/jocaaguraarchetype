import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Helpers
bool _nearInt(int a, int b, {int tol = 2}) => (a - b).abs() <= tol;

bool _nearColor(Color a, Color b, {int tol = 2}) =>
    _nearInt((a.r * 255).round(), (b.r * 255).round(), tol: tol) &&
    _nearInt((a.g * 255).round(), (b.g * 255).round(), tol: tol) &&
    _nearInt((a.b * 255).round(), (b.b * 255).round(), tol: tol) &&
    a.a == b.a;

void main() {
  group('ThemeColorUtils.validateHexColor', () {
    test('acepta formatos válidos #RRGGBB (upper/lower)', () {
      expect(ThemeColorUtils.validateHexColor('#FFFFFF'), isTrue);
      expect(ThemeColorUtils.validateHexColor('#000000'), isTrue);
      expect(ThemeColorUtils.validateHexColor('#a1b2c3'), isTrue);
      expect(ThemeColorUtils.validateHexColor('#AaBbCc'), isTrue);
    });

    test('rechaza strings inválidos o longitudes incorrectas', () {
      expect(ThemeColorUtils.validateHexColor('FFFFFF'), isFalse,
          reason: 'sin #');
      expect(ThemeColorUtils.validateHexColor('#FFF'), isFalse,
          reason: '3 dígitos');
      expect(ThemeColorUtils.validateHexColor('#FFFFF'), isFalse,
          reason: '5 dígitos');
      expect(ThemeColorUtils.validateHexColor('#FFFFFG'), isFalse,
          reason: 'carácter fuera de [0-9A-Fa-f]');
      expect(ThemeColorUtils.validateHexColor('#12 4AF'), isFalse,
          reason: 'espacios');
      expect(ThemeColorUtils.validateHexColor(''), isFalse);
    });
  });

  group('ThemeColorUtils.convertToLab / convertToRgb', () {
    test('round-trip RGB → LAB → RGB mantiene color con tolerancia', () {
      const List<Color> samples = <Color>[
        Color(0xFF112233),
        Color(0xFFabcdef),
        Color(0xFFCC8844),
        Color(0xFF0099FF),
        Color(0xFF00FF00),
        Color(0xFFFF0000),
        Color(0xFF000000),
        Color(0xFFFFFFFF),
      ];

      for (final Color c in samples) {
        final LabColor lab = ThemeColorUtils.convertToLab(c);
        final Color back = ThemeColorUtils.convertToRgb(lab);
        expect(
          _nearColor(back, c),
          isTrue,
          reason:
              'RGB→LAB→RGB debería conservar (±2 por canal) para $c, obtuvo $back',
        );
      }
    });
  });

  group('ThemeColorUtils.getDarker / getLighter', () {
    test('asserts de amount fuera de rango lanzan AssertionError', () {
      const Color base = Color(0xFF6699CC);
      expect(() => ThemeColorUtils.getDarker(base, amount: 0),
          throwsAssertionError);
      expect(() => ThemeColorUtils.getDarker(base, amount: 1),
          throwsAssertionError);
      expect(() => ThemeColorUtils.getLighter(base, amount: 0),
          throwsAssertionError);
      expect(() => ThemeColorUtils.getLighter(base, amount: 1),
          throwsAssertionError);
    });

    test('variar lightness en LAB produce colores más oscuros/claros', () {
      const Color base = Color(0xFF6699CC);
      final LabColor lab = ThemeColorUtils.convertToLab(base);

      final Color darker10 = ThemeColorUtils.getDarker(base);
      final Color lighter10 = ThemeColorUtils.getLighter(base);

      final LabColor labD = ThemeColorUtils.convertToLab(darker10);
      final LabColor labL = ThemeColorUtils.convertToLab(lighter10);

      expect(labD.lightness, lessThan(lab.lightness));
      expect(labL.lightness, greaterThan(lab.lightness));

      // Canales RGB válidos
      for (final Color c in <Color>[darker10, lighter10]) {
        expect(c.r * 255, inInclusiveRange(0, 255));
        expect(c.g * 255, inInclusiveRange(0, 255));
        expect(c.b * 255, inInclusiveRange(0, 255));
      }
    });

    test('encadenar más amount intensifica el efecto', () {
      const Color base = Color(0xFF6699CC);

      final Color darker10 = ThemeColorUtils.getDarker(base);
      final Color darker30 = ThemeColorUtils.getDarker(base, amount: .30);

      final double lBase = ThemeColorUtils.convertToLab(base).lightness;
      final double l10 = ThemeColorUtils.convertToLab(darker10).lightness;
      final double l30 = ThemeColorUtils.convertToLab(darker30).lightness;

      expect(l10, lessThan(lBase));
      expect(l30, lessThan(l10), reason: 'más amount → más oscuro');

      final Color lighter10 = ThemeColorUtils.getLighter(base);
      final Color lighter30 = ThemeColorUtils.getLighter(base, amount: .30);

      final double lb10 = ThemeColorUtils.convertToLab(lighter10).lightness;
      final double lb30 = ThemeColorUtils.convertToLab(lighter30).lightness;

      expect(lb10, greaterThan(lBase));
      expect(lb30, greaterThan(lb10), reason: 'más amount → más claro');
    });
  });

  group('ThemeColorUtils.materialColorFromRGB', () {
    test('asserts en canales fuera de rango', () {
      expect(() => ThemeColorUtils.materialColorFromRGB(-1, 0, 0),
          throwsAssertionError);
      expect(() => ThemeColorUtils.materialColorFromRGB(0, 256, 0),
          throwsAssertionError);
      expect(() => ThemeColorUtils.materialColorFromRGB(0, 0, 999),
          throwsAssertionError);
    });

    test('estructura del MaterialColor y consistencia del tono 500', () {
      final MaterialColor mc =
          ThemeColorUtils.materialColorFromRGB(102, 153, 204); // 0xFF6699CC
      expect(mc.toARGB32(), const Color(0xFF6699CC).toARGB32());
      expect(mc[500], const Color(0xFF6699CC));

      // todos los tonos presentes
      const List<int> keys = <int>[
        50,
        100,
        200,
        300,
        400,
        500,
        600,
        700,
        800,
        900
      ];
      for (final int k in keys) {
        expect(mc[k], isA<Color>(), reason: 'Debe tener shade $k');
      }
    });

    test('gradiente de luminosidad: 50..400 > 500 > 600..900', () {
      final MaterialColor mc =
          ThemeColorUtils.materialColorFromRGB(102, 153, 204);
      final double l500 = ThemeColorUtils.convertToLab(mc[500]!).lightness;

      for (final int k in <int>[50, 100, 200, 300, 400]) {
        final double l = ThemeColorUtils.convertToLab(mc[k]!).lightness;
        expect(l, greaterThan(l500),
            reason: 'shade $k debería ser más claro que 500');
      }
      for (final int k in <int>[600, 700, 800, 900]) {
        final double l = ThemeColorUtils.convertToLab(mc[k]!).lightness;
        expect(l, lessThan(l500),
            reason: 'shade $k debería ser más oscuro que 500');
      }
    });
  });
}
