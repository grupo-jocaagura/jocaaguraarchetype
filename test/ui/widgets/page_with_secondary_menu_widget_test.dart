import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('PageWithSecondaryMenuWidget', () {
    // ---- Helpers -----------------------------------------------------------

    const Size mobileSize = Size(360, 640);
    const Size desktopSize = Size(1280, 800);

    BlocResponsive mobileResp() {
      final BlocResponsive r = BlocResponsive()..setSizeForTesting(mobileSize);
      return r;
    }

    BlocResponsive desktopResp() {
      final BlocResponsive r = BlocResponsive()..setSizeForTesting(desktopSize);
      return r;
    }

    Future<void> setSurfaceSize(WidgetTester tester, Size size) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = Size(size.width, size.height);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    Future<void> pumpPage(
      WidgetTester tester, {
      required BlocResponsive r,
      required Size surfaceSize,
      required Widget content,
      Widget? secondary,
      int panelColumns = 2,
      bool secondaryOnRight = true,
      bool animate = true,
      Color? backgroundColor,
      bool safeArea = true,
    }) async {
      await setSurfaceSize(tester, surfaceSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PageWithSecondaryMenuWidget(
              responsive: r,
              content: content,
              secondaryMenu: secondary,
              panelColumns: panelColumns,
              secondaryOnRight: secondaryOnRight,
              animate: animate,
              backgroundColor: backgroundColor,
              safeArea: safeArea,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    // ---- Tests -------------------------------------------------------------

    testWidgets('móvil: muestra overlay inferior cuando hay secondaryMenu',
        (WidgetTester tester) async {
      final BlocResponsive r = mobileResp();
      await pumpPage(
        tester,
        r: r,
        surfaceSize: mobileSize,
        content: Container(
          key: const Key('content'),
          color: Colors.blue,
          height: 200,
        ),
        secondary: Container(key: const Key('secondary'), height: 40),
      );

      // El overlay usa _maybeAnimated con key 'mobile-secondary'
      expect(
        find.byKey(const ValueKey<String>('mobile-secondary')),
        findsOneWidget,
      );
      // El contenido existe
      expect(find.byKey(const Key('content')), findsOneWidget);
      // El secondary existe
      expect(find.byKey(const Key('secondary')), findsOneWidget);
    });

    testWidgets('móvil: no muestra overlay si secondaryMenu es null',
        (WidgetTester tester) async {
      final BlocResponsive r = mobileResp();
      await pumpPage(
        tester,
        r: r,
        surfaceSize: mobileSize,
        content: Container(key: const Key('content')),
      );

      expect(
        find.byKey(const ValueKey<String>('mobile-secondary')),
        findsNothing,
      );
    });

    testWidgets('escritorio: ancho del panel = widthByColumns(panelColumns)',
        (WidgetTester tester) async {
      final BlocResponsive r = desktopResp();
      const int cols = 3;

      await pumpPage(
        tester,
        r: r,
        surfaceSize: desktopSize,
        content: Container(key: const Key('content')),
        secondary: Container(key: const Key('secondary')),
        panelColumns: cols,
      );

      // AnimatedSwitcher del panel (animate=true por defecto)
      final Finder panelSwitcher =
          find.byKey(const ValueKey<String>('panel-secondary'));
      expect(panelSwitcher, findsOneWidget);

      final double expectedPanelW =
          r.widthByColumns(cols.clamp(1, r.columnsNumber));

      // Medimos el ancho real del switcher (igual al SizedBox de panel).
      final Size actualSize = tester.getSize(panelSwitcher);

      expect(
        (actualSize.width - expectedPanelW).abs() < 0.001,
        isTrue,
        reason: 'ancho real ${actualSize.width} vs esperado $expectedPanelW',
      );
    });

    testWidgets('escritorio: panel a la derecha por defecto',
        (WidgetTester tester) async {
      final BlocResponsive r = desktopResp();

      await pumpPage(
        tester,
        r: r,
        surfaceSize: desktopSize,
        content: Container(
          key: const Key('content'),
          width: 200,
          height: 200,
          color: Colors.green,
        ),
        secondary: Container(
          key: const Key('secondary'),
          width: 120,
          height: 100,
          color: Colors.red,
        ),
      );

      final Offset contentPos =
          tester.getTopLeft(find.byKey(const Key('content')));
      final Offset secondaryPos =
          tester.getTopLeft(find.byKey(const Key('secondary')));

      expect(secondaryPos.dx, greaterThan(contentPos.dx));
    });

    testWidgets(
        'escritorio: panel a la izquierda cuando secondaryOnRight=false',
        (WidgetTester tester) async {
      final BlocResponsive r = desktopResp();

      await pumpPage(
        tester,
        r: r,
        surfaceSize: desktopSize,
        content: const SizedBox(key: Key('content'), width: 200, height: 200),
        secondary:
            const SizedBox(key: Key('secondary'), width: 120, height: 100),
        secondaryOnRight: false,
      );

      final Offset contentPos =
          tester.getTopLeft(find.byKey(const Key('content')));
      final Offset secondaryPos =
          tester.getTopLeft(find.byKey(const Key('secondary')));

      expect(secondaryPos.dx, lessThan(contentPos.dx));
    });

    testWidgets('aplica backgroundColor al contenedor raíz',
        (WidgetTester tester) async {
      final BlocResponsive r = desktopResp();
      const Color bg = Colors.amber;

      await pumpPage(
        tester,
        r: r,
        surfaceSize: desktopSize,
        content: const SizedBox(),
        secondary: const SizedBox(),
        backgroundColor: bg,
      );

      // Busca algún Container con ese color (el root del layout de página)
      final Finder rootContainer = find.byWidgetPredicate(
        (Widget w) => w is Container && w.color == bg,
      );
      expect(rootContainer, findsOneWidget);
    });

    testWidgets('safeArea=true envuelve el contenido en SafeArea',
        (WidgetTester tester) async {
      final BlocResponsive r = desktopResp();

      await pumpPage(
        tester,
        r: r,
        surfaceSize: desktopSize,
        content: const SizedBox(),
        secondary: const SizedBox(),
      );

      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('safeArea=false no inserta SafeArea',
        (WidgetTester tester) async {
      final BlocResponsive r = desktopResp();

      await pumpPage(
        tester,
        r: r,
        surfaceSize: desktopSize,
        content: const SizedBox(),
        secondary: const SizedBox(),
        safeArea: false,
      );

      expect(find.byType(SafeArea), findsNothing);
    });

    testWidgets('animate=false no crea los AnimatedSwitcher con keys',
        (WidgetTester tester) async {
      final BlocResponsive r = desktopResp();

      await pumpPage(
        tester,
        r: r,
        surfaceSize: desktopSize,
        content: const SizedBox(),
        secondary: const SizedBox(),
        animate: false,
      );

      expect(
        find.byKey(const ValueKey<String>('panel-secondary')),
        findsNothing,
      );

      // Móvil también sin switcher
      await pumpPage(
        tester,
        r: mobileResp(),
        surfaceSize: mobileSize,
        content: const SizedBox(),
        secondary: const SizedBox(),
        animate: false,
      );
      expect(
        find.byKey(const ValueKey<String>('mobile-secondary')),
        findsNothing,
      );
    });

    testWidgets('cuando no hay secondaryMenu, no se reserva ancho de panel',
        (WidgetTester tester) async {
      final BlocResponsive r = desktopResp();

      await pumpPage(
        tester,
        r: r,
        surfaceSize: desktopSize,
        content: const SizedBox(),
        panelColumns: 4,
      );

      expect(
        find.byKey(const ValueKey<String>('panel-secondary')),
        findsNothing,
      );
    });
  });
}
