import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('LabColor · colorToLab (conocidos sRGB→Lab aprox)', () {
    // Tolerancias “de ingeniería” por redondeos/gamma
    const double tolL = 0.6;
    const double tola = 1.0;
    const double tolb = 1.0;

    test('Rojo puro (255,0,0) ~ L≈53.2 a≈80.1 b≈67.2', () {
      final List<double> lab = LabColor.colorToLab(const Color(0xFFFF0000));
      expect(lab[0], closeTo(53.24, tolL));
      expect(lab[1], closeTo(80.09, tola));
      expect(lab[2], closeTo(67.20, tolb));
    });

    test('Verde puro (0,255,0) ~ L≈87.73 a≈−86.18 b≈83.18', () {
      final List<double> lab = LabColor.colorToLab(const Color(0xFF00FF00));
      expect(lab[0], closeTo(87.73, 0.8));
      expect(lab[1], closeTo(-86.18, 1.2));
      expect(lab[2], closeTo(83.18, 1.2));
    });

    test('Azul puro (0,0,255) ~ L≈32.30 a≈79.20 b≈−107.86', () {
      final List<double> lab = LabColor.colorToLab(const Color(0xFF0000FF));
      expect(lab[0], closeTo(32.30, 0.8));
      expect(lab[1], closeTo(79.20, 1.2));
      expect(lab[2], closeTo(-107.86, 1.8));
    });
  });

  group('LabColor · Round-trip RGB→Lab→RGB', () {
    test('colores aleatorios quedan a ±1 por canal', () {
      final Random rnd = Random(42);
      for (int i = 0; i < 25; i += 1) {
        final int r = rnd.nextInt(256);
        final int g = rnd.nextInt(256);
        final int b = rnd.nextInt(256);

        final List<double> lab = LabColor.colorToLab(Color.fromARGB(255, r, g, b));
        final List<int> rgb = LabColor.labToColor(lab[0], lab[1], lab[2]);

        expect((rgb[0] - r).abs(), lessThanOrEqualTo(1));
      expect((rgb[1] - g).abs(), lessThanOrEqualTo(1));
      expect((rgb[2] - b).abs(), lessThanOrEqualTo(1));
    }
    });
  });

  group('LabColor · Monotonicidad de L', () {
    test('subir L +10 eleva la L medida tras round-trip', () {
      const Color base = Color(0xFF4A90E2); // azul medio
      final List<double> lab0 = LabColor.colorToLab(base);

      final List<int> rgbUp =
      LabColor.labToColor(lab0[0] + 10.0, lab0[1], lab0[2]);
      final List<double> labUp =
      LabColor.colorToLab(Color.fromARGB(255, rgbUp[0], rgbUp[1], rgbUp[2]));

      expect(labUp[0], greaterThan(lab0[0]));
    });

    test('bajar L -10 reduce la L medida tras round-trip', () {
      const Color base = Color(0xFF4A90E2);
      final List<double> lab0 = LabColor.colorToLab(base);

      final List<int> rgbDown =
      LabColor.labToColor(lab0[0] - 10.0, lab0[1], lab0[2]);
      final List<double> labDown =
      LabColor.colorToLab(Color.fromARGB(255, rgbDown[0], rgbDown[1], rgbDown[2]));

      expect(labDown[0], lessThan(lab0[0]));
    });
  });

  group('LabColor · utilitarios ARGB', () {
    test('colorValue produce ARGB esperado', () {
      final int v = LabColor.colorValue(0x12, 0x34, 0x56);
      expect(v, 0xFF123456);
    });

    test('colorValueFromColor extrae canales nativos', () {
      const Color c = Color(0xFFABCDEF);
      expect(LabColor.colorValueFromColor(c), 0xFFABCDEF);
    });
  });
}
