import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

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
      expect(
        responsiveBloc.secondaryDrawerWidth,
        greaterThanOrEqualTo(71.8),
      );
      expect(responsiveBloc.appBarHeight, kAppBarHeight);
      expect(responsiveBloc.gutterWidth, 10.0);
      expect(responsiveBloc.marginWidth, 64);
      expect(responsiveBloc.screenHeightWithoutAppbar, 660.0);

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

      responsiveBloc.showAppbar = false;
      expect(responsiveBloc.showAppbar, false);
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
    test('should provide showAppbarStream', () async {
      // Create an instance of BlocResponsive
      final BlocResponsive blocResponsive = BlocResponsive();

      // Check if the showAppbarStream is not null
      expect(blocResponsive.showAppbarStream, isNotNull);
      expect(blocResponsive.showAppbarStream, emits(true));
      blocResponsive.showAppbar = false;
      expect(blocResponsive.showAppbar, false);
    });
    test('Verify isClosed', () async {
      // Create an instance of BlocResponsive
      final BlocResponsive blocResponsive = BlocResponsive();
      blocResponsive.dispose();
      // Check if the showAppbarStream is not null
      expect(blocResponsive.showAppBarStreamIsClosed, true);
      expect(blocResponsive.appScreenSizeStreamIsClosed, true);
    });

    testWidgets('setSizeFromContext updates size correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () {
                  responsiveBloc.setSizeFromContext(context);
                },
                child: const Text('Actualizar tamaño'),
              );
            },
          ),
        ),
      );

      tester.view.physicalSize = const Size(1920, 1080);

      tester.view.devicePixelRatio = 1.0;

      await tester.pump();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(responsiveBloc.isTv, true);
      expect(
        responsiveBloc.workAreaSize,
        equals(
          const Size(1536.0, 1080.0),
        ),
      );
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
