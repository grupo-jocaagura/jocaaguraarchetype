import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/blocs/bloc_responsive.dart';

// revisado 10/03/2024 author: @albertjjimenezp
void main() {
  group('ResponsiveBloc', () {
    late BlocResponsive responsiveBloc;

    setUp(() {
      responsiveBloc = BlocResponsive();
    });

    tearDown(() {
      responsiveBloc.dispose();
    });

    test('Initial value should be Size.zero', () {
      expect(responsiveBloc.value, Size.zero);
    });

    test('setSizeFromContext should update the value', () {
      const Size contextSize = Size(320, 480);
      responsiveBloc.setSizeForTesting(contextSize);
      expect(responsiveBloc.value, contextSize);
    });

    test('setSizeForTesting should update the value', () {
      const Size testSize = Size(800, 600);
      responsiveBloc.setSizeForTesting(testSize);
      expect(responsiveBloc.value, testSize);
    });

    test('workAreaSize should return size if isMovil is true', () {
      const Size size = Size(320, 480);
      responsiveBloc.setSizeForTesting(size);
      expect(responsiveBloc.workAreaSize, size);
    });

    test('workAreaSize should return _workAreaSize if isMovil is false', () {
      const Size size = Size(1280, 720);
      const Size workAreaSize = Size(1100.8, 720);
      responsiveBloc.setSizeForTesting(size);
      responsiveBloc.workAreaSize = size;
      expect(responsiveBloc.workAreaSize, workAreaSize);
      expect(responsiveBloc.columnsNumber, 12);
      expect(responsiveBloc.columnWidth, greaterThanOrEqualTo(71.8));
      expect(responsiveBloc.gutterWidth, 10.0);
      expect(responsiveBloc.marginWidth, 64);
      const Size sizeTablet = Size(1100, 720);
      const Size workAreaSizeTablet = Size(1100, 720);
      expect(responsiveBloc.drawerWidth, greaterThanOrEqualTo(179.2));
      responsiveBloc.setSizeForTesting(sizeTablet);
      responsiveBloc.workAreaSize = sizeTablet;
      expect(responsiveBloc.workAreaSize, workAreaSizeTablet);
      expect(responsiveBloc.columnsNumber, 8);
      final double mg = responsiveBloc.marginWidth;
      final double mg2 = responsiveBloc.widthByColumns(3);
      expect(mg, 32);
      expect(mg2, 383.5);
      expect(responsiveBloc.columnWidth, 122.5);
      expect(responsiveBloc.gutterWidth, 8.0);
    });
    test('should provide appScreenSizeStream', () {
      // Create an instance of BlocResponsive
      final BlocResponsive blocResponsive = BlocResponsive();

      // Get the appScreenSizeStream
      final Stream<Size> appScreenSizeStream =
          blocResponsive.appScreenSizeStream;

      // Check if the appScreenSizeStream is not null
      expect(appScreenSizeStream, isNotNull);
    });

    // Write additional tests to cover other methods and properties of the ResponsiveBloc
  });
}
