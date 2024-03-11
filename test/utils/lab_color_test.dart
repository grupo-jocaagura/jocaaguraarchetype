import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/utils/lab_color.dart';
// revisado 10/03/2024 author: @albertjjimenezp

void main() {
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
}
