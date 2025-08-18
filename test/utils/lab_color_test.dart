import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('Initial tests', () {
    test('Test colorToLab', () {
      const Color color = Color.fromRGBO(255, 0, 0, 1);
      final List<double> lab = LabColor.colorToLab(color);
      expect(
        nearEqual(lab[0], lab[0], 1),
        nearEqual(53.24, 53.24, 1),
      );
    });

    test('Test rgbToXyz', () {
      final List<double> xyz = LabColor.rgbToXyz(255, 0, 0);
      expect(
        nearEqual(
          xyz[0],
          xyz[0],
          1,
        ),
        nearEqual(
          41.2464,
          41.2464,
          1,
        ),
      );
    });

    test('Test xyzToLab', () {
      final List<double> lab = LabColor.xyzToLab(
        41.24642268041237,
        21.267213114754098,
        1.9338842975206612,
      );
      expect(
        nearEqual(lab[0], lab[0], 1),
        nearEqual(53.2407, 53.2407, 1),
      );
    });

    test('Test labToColor', () {
      final List<int> color = LabColor.labToColor(
        53.24079414146717,
        80.09245959669247,
        67.20319618020961,
      );
      expect(color, equals(<double>[255, 0, 0]));
    });
  });
  group('LabColor.colorValue', () {
    test('Debe generar el valor ARGB correcto para un color dado', () {
      final int result = LabColor.colorValue(255, 0, 0); // Rojo puro
      expect(result, equals(0xFFFF0000));
    });

    test(
        'Debe generar el valor ARGB correcto para un color con componentes mixtos',
        () {
      final int result = LabColor.colorValue(128, 128, 128); // Gris medio
      expect(result, equals(0xFF808080));
    });

    test('Debe generar el valor ARGB correcto para negro', () {
      final int result = LabColor.colorValue(0, 0, 0); // Negro
      expect(result, equals(0xFF000000));
    });

    test('Debe generar el valor ARGB correcto para blanco', () {
      final int result = LabColor.colorValue(255, 255, 255); // Blanco
      expect(result, equals(0xFFFFFFFF));
    });

    test('Debe lanzar una excepción si los valores están fuera de rango', () {
      expect(
        () => LabColor.colorValue(-1, 0, 0),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => LabColor.colorValue(256, 0, 0),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('LabColor.colorValueFromColor', () {
    test('Debe generar el valor ARGB correcto para un color Material', () {
      const Color color = Color(0xFF00FF00); // Verde puro
      final int result = LabColor.colorValueFromColor(color);
      expect(result, equals(0xFF00FF00));
    });

    test('Debe manejar colores con componentes mixtos correctamente', () {
      const Color color = Color(0xFF123456); // Color arbitrario
      final int result = LabColor.colorValueFromColor(color);
      expect(result, equals(0xFF123456));
    });

    test('Debe generar el valor ARGB correcto para negro', () {
      const Color color = Color(0xFF000000); // Negro
      final int result = LabColor.colorValueFromColor(color);
      expect(result, equals(0xFF000000));
    });

    test('Debe generar el valor ARGB correcto para blanco', () {
      const Color color = Color(0xFFFFFFFF); // Blanco
      final int result = LabColor.colorValueFromColor(color);
      expect(result, equals(0xFFFFFFFF));
    });
  });
}
