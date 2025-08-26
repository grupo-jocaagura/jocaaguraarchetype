import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// --------- Fake BlocResponsive minimal, coherente con el resto de tests ---------
class FakeBlocResponsive extends BlocResponsive {
  FakeBlocResponsive({
    required this.deviceType,
    required this.workAreaSize,
    required this.columnsNumber,
    required this.marginWidth,
    double? gutterWidth,
  }) : _gutterOverride = gutterWidth;

  @override
  final ScreenSizeEnum deviceType;

  @override
  final Size workAreaSize;

  @override
  final int columnsNumber;

  @override
  final double marginWidth;

  final double? _gutterOverride;

  bool setFromCtxCalled = false;

  @override
  void setSizeFromContext(BuildContext context) {
    setFromCtxCalled = true;
  }

  @override
  bool get isMobile => deviceType == ScreenSizeEnum.mobile;

  @override
  double get gutterWidth =>
      (_gutterOverride ?? ((marginWidth * 2) / columnsNumber)).floorToDouble();

  int _numberOfGutters(int cols) => (cols <= 1) ? 0 : cols - 1;

  @override
  double get columnWidth {
    double w = workAreaSize.width;
    w = w - (marginWidth * 2);
    w = w - (_numberOfGutters(columnsNumber) * gutterWidth);
    w = w / columnsNumber;
    return w.clamp(0.0, double.maxFinite).floorToDouble();
  }

  @override
  double widthByColumns(int numberOfColumns) {
    final int cols = numberOfColumns.abs().clamp(1, columnsNumber);
    double w = columnWidth * cols;
    if (cols > 1) {
      w += gutterWidth * (cols - 1);
    }
    return w.floorToDouble();
  }
}

/// ---------- Helpers ----------
Future<void> _pump(
  WidgetTester tester, {
  required Widget child,
  Size surface = const Size(800, 600),
  ThemeData? theme,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme ?? ThemeData(useMaterial3: true),
      home: MediaQuery(
        data: MediaQueryData(size: surface),
        child: Scaffold(body: child),
      ),
    ),
  );
  // No usamos pumpAndSettle por los timers/animaciones; bombeamos frames puntuales en cada test.
  await tester.pump(const Duration(milliseconds: 1));
}

// Obtiene el Align específico dentro del widget (topRight/bottomCenter según dispositivo).
Align _findAlignUnderSnack(WidgetTester tester) {
  final Finder f = find.descendant(
    of: find.byType(MySnackBarWidget),
    matching: find.byType(Align),
  );
  return tester.widget<Align>(f.first);
}

// Busca el ConstrainedBox que el toast usa para limitar ancho y lo devuelve.
ConstrainedBox _findToastConstrainedBox(WidgetTester tester) {
  tester.widgetList(find.byType(ConstrainedBox));
  // Elegimos el que vive bajo el Material del toast
  final Finder materialFinder = find.byWidgetPredicate(
    (Widget w) => w is Material && w.elevation == 8.0,
  );
  expect(materialFinder, findsOneWidget);
  final Element materialEl = tester.element(materialFinder);
  final ConstrainedBox cb =
      materialEl.findAncestorWidgetOfExactType<ConstrainedBox>()!;
  return cb;
}

void main() {
  group('MySnackBarWidget - layout responsivo y sizing', () {
    testWidgets('mobile: bottomCenter y maxWidth = workArea - 2*margin',
        (WidgetTester tester) async {
      final FakeBlocResponsive resp = FakeBlocResponsive(
        deviceType: ScreenSizeEnum.mobile,
        workAreaSize: const Size(360, 640),
        columnsNumber: 4,
        marginWidth: 16,
        gutterWidth: 12, // gap=12
      );

      final StreamController<AppSnack> ctrl = StreamController<AppSnack>();
      final MySnackBarWidget w = MySnackBarWidget(
        responsive: resp,
        snacks: ctrl.stream,
      );

      await _pump(tester, child: w, surface: const Size(360, 640));
      // Emitimos snack largo para forzar ancho máximo
      ctrl.add(AppSnack.info('x' * 200));
      await tester.pump(const Duration(milliseconds: 30)); // que se construya

      // Align esperado
      final Align a = _findAlignUnderSnack(tester);
      expect(a.alignment, Alignment.bottomCenter);

      // MaxWidth esperado
      final double expectedMax =
          resp.workAreaSize.width - resp.marginWidth * 2; // 360-32=328
      final ConstrainedBox cb = _findToastConstrainedBox(tester);
      expect(cb.constraints.maxWidth, expectedMax);

      // setSizeFromContext() fue llamado
      expect(resp.setFromCtxCalled, isTrue);

      await ctrl.close();
    });

    testWidgets('desktop: topRight por defecto y maxWidth = widthByColumns(4)',
        (WidgetTester tester) async {
      final FakeBlocResponsive resp = FakeBlocResponsive(
        deviceType: ScreenSizeEnum.desktop,
        workAreaSize: const Size(1024, 700),
        columnsNumber: 12,
        marginWidth: 16,
        gutterWidth: 10,
      );

      final StreamController<AppSnack> ctrl = StreamController<AppSnack>();
      final MySnackBarWidget w = MySnackBarWidget(
        responsive: resp,
        snacks: ctrl.stream,
      );

      await _pump(tester, child: w, surface: const Size(1024, 700));
      ctrl.add(AppSnack.info('mensaje muy largo ' * 20));
      await tester.pump(const Duration(milliseconds: 30));

      final Align a = _findAlignUnderSnack(tester);
      expect(a.alignment, Alignment.topRight);

      final double expectedMax = resp.widthByColumns(4);
      final ConstrainedBox cb = _findToastConstrainedBox(tester);
      expect(cb.constraints.maxWidth, expectedMax);

      await ctrl.close();
    });

    testWidgets('maxWidthColumns sobrescribe el default',
        (WidgetTester tester) async {
      final FakeBlocResponsive resp = FakeBlocResponsive(
        deviceType: ScreenSizeEnum.desktop,
        workAreaSize: const Size(1200, 800),
        columnsNumber: 12,
        marginWidth: 20,
        gutterWidth: 10,
      );

      final StreamController<AppSnack> ctrl = StreamController<AppSnack>();
      final MySnackBarWidget w = MySnackBarWidget(
        responsive: resp,
        snacks: ctrl.stream,
        maxWidthColumns: 6,
      );

      await _pump(tester, child: w, surface: const Size(1200, 800));
      ctrl.add(AppSnack.info('x' * 300));
      await tester.pump(const Duration(milliseconds: 30));

      final double expectedMax = resp.widthByColumns(6);
      final ConstrainedBox cb = _findToastConstrainedBox(tester);
      expect(cb.constraints.maxWidth, expectedMax);

      await ctrl.close();
    });

    testWidgets('safeArea=false no envuelve con SafeArea',
        (WidgetTester tester) async {
      final FakeBlocResponsive resp = FakeBlocResponsive(
        deviceType: ScreenSizeEnum.mobile,
        workAreaSize: const Size(360, 640),
        columnsNumber: 4,
        marginWidth: 16,
        gutterWidth: 12,
      );

      final StreamController<AppSnack> ctrl = StreamController<AppSnack>();
      final MySnackBarWidget w = MySnackBarWidget(
        responsive: resp,
        snacks: ctrl.stream,
        safeArea: false,
      );

      await _pump(tester, child: w, surface: const Size(360, 640));
      ctrl.add(AppSnack.info('Hola'));
      await tester.pump(const Duration(milliseconds: 30));

      // No hay SafeArea bajo el widget
      final Finder safe = find.descendant(
        of: find.byType(MySnackBarWidget),
        matching: find.byType(SafeArea),
      );
      expect(safe, findsNothing);

      await ctrl.close();
    });
  });

  group('MySnackBarWidget - cola, tiempos y auto-cierre', () {
    testWidgets('muestra snack y auto-cierra después de su duración',
        (WidgetTester tester) async {
      final FakeBlocResponsive resp = FakeBlocResponsive(
        deviceType: ScreenSizeEnum.mobile,
        workAreaSize: const Size(360, 640),
        columnsNumber: 4,
        marginWidth: 16,
        gutterWidth: 12,
      );

      final StreamController<AppSnack> ctrl = StreamController<AppSnack>();
      final MySnackBarWidget w = MySnackBarWidget(
        responsive: resp,
        snacks: ctrl.stream,
        duration:
            const Duration(seconds: 5), // default alto para comprobar override
      );

      await _pump(tester, child: w);

      ctrl.add(
        AppSnack.info('auto', duration: const Duration(milliseconds: 120)),
      );
      await tester.pump(const Duration(milliseconds: 20));
      expect(find.text('auto'), findsOneWidget);

      // Esperamos a que expire + animación de salida (220ms)
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(milliseconds: 240));
      expect(find.text('auto'), findsNothing);

      await ctrl.close();
    });

    testWidgets('encola dos snacks y los muestra secuencialmente',
        (WidgetTester tester) async {
      final FakeBlocResponsive resp = FakeBlocResponsive(
        deviceType: ScreenSizeEnum.desktop,
        workAreaSize: const Size(900, 700),
        columnsNumber: 12,
        marginWidth: 16,
        gutterWidth: 10,
      );

      final StreamController<AppSnack> ctrl = StreamController<AppSnack>();
      final MySnackBarWidget w =
          MySnackBarWidget(responsive: resp, snacks: ctrl.stream);

      await _pump(tester, child: w);

      ctrl.add(
        AppSnack.info('uno', duration: const Duration(milliseconds: 100)),
      );
      ctrl.add(
        AppSnack.info('dos', duration: const Duration(milliseconds: 100)),
      );

      await tester.pump(const Duration(milliseconds: 30));
      expect(find.text('uno'), findsOneWidget);

      // Deja que termine el primero
      await tester.pump(const Duration(milliseconds: 130)); // oculta
      await tester
          .pump(const Duration(milliseconds: 230)); // show next tras 220ms
      expect(find.text('uno'), findsNothing);
      expect(find.text('dos'), findsOneWidget);

      // Deja que termine el segundo
      await tester.pump(const Duration(milliseconds: 130));
      await tester.pump(const Duration(milliseconds: 230));
      expect(find.text('dos'), findsNothing);

      await ctrl.close();
    });
  });

  group('MySnackBarWidget - acción y dismiss', () {
    testWidgets('action dispara callback y oculta el snack',
        (WidgetTester tester) async {
      final FakeBlocResponsive resp = FakeBlocResponsive(
        deviceType: ScreenSizeEnum.desktop,
        workAreaSize: const Size(1024, 700),
        columnsNumber: 12,
        marginWidth: 16,
        gutterWidth: 10,
      );

      int calls = 0;
      final StreamController<AppSnack> ctrl = StreamController<AppSnack>();
      final MySnackBarWidget w =
          MySnackBarWidget(responsive: resp, snacks: ctrl.stream);

      await _pump(tester, child: w);

      ctrl.add(
        AppSnack.success(
          'ok',
          actionLabel: 'UNDO',
          onAction: () => calls++,
          duration: const Duration(seconds: 10),
        ),
      );
      await tester.pump(const Duration(milliseconds: 30));
      expect(find.text('ok'), findsOneWidget);
      expect(find.text('UNDO'), findsOneWidget);

      await tester.tap(find.text('UNDO'));
      await tester.pump(const Duration(milliseconds: 10));
      expect(calls, 1);

      // Tras acción se oculta
      await tester.pump(const Duration(milliseconds: 240));
      expect(find.text('ok'), findsNothing);

      await ctrl.close();
    });

    testWidgets('dismissible: botón Close oculta el snack',
        (WidgetTester tester) async {
      final FakeBlocResponsive resp = FakeBlocResponsive(
        deviceType: ScreenSizeEnum.mobile,
        workAreaSize: const Size(360, 640),
        columnsNumber: 4,
        marginWidth: 16,
        gutterWidth: 12,
      );

      final StreamController<AppSnack> ctrl = StreamController<AppSnack>();
      final MySnackBarWidget w =
          MySnackBarWidget(responsive: resp, snacks: ctrl.stream);

      await _pump(tester, child: w);

      ctrl.add(
        AppSnack.warning('cierra', duration: const Duration(seconds: 5)),
      );
      await tester.pump(const Duration(milliseconds: 30));
      expect(find.text('cierra'), findsOneWidget);

      // El IconButton tiene tooltip 'Close'
      await tester.tap(find.byTooltip('Close'));
      await tester.pump(const Duration(milliseconds: 20));
      await tester.pump(const Duration(milliseconds: 240)); // salida
      expect(find.text('cierra'), findsNothing);

      await ctrl.close();
    });

    testWidgets('dismissible=false: no muestra botón Close',
        (WidgetTester tester) async {
      final FakeBlocResponsive resp = FakeBlocResponsive(
        deviceType: ScreenSizeEnum.tablet,
        workAreaSize: const Size(720, 640),
        columnsNumber: 12,
        marginWidth: 16,
        gutterWidth: 10,
      );

      final StreamController<AppSnack> ctrl = StreamController<AppSnack>();
      final MySnackBarWidget w = MySnackBarWidget(
        responsive: resp,
        snacks: ctrl.stream,
        dismissible: false,
      );

      await _pump(tester, child: w);

      ctrl.add(
        AppSnack.error('sin close', duration: const Duration(seconds: 3)),
      );
      await tester.pump(const Duration(milliseconds: 30));

      expect(find.byTooltip('Close'), findsNothing);
      expect(find.text('sin close'), findsOneWidget);

      await ctrl.close();
    });
  });

  group('MySnackBarWidget - fábrica fromStringStream y Semantics', () {
    testWidgets('fromStringStream mapea a AppSnack.info y lo muestra',
        (WidgetTester tester) async {
      final FakeBlocResponsive resp = FakeBlocResponsive(
        deviceType: ScreenSizeEnum.desktop,
        workAreaSize: const Size(900, 700),
        columnsNumber: 12,
        marginWidth: 16,
        gutterWidth: 10,
      );

      final StreamController<String> ctrl = StreamController<String>();
      final MySnackBarWidget w = MySnackBarWidget.fromStringStream(
        responsive: resp,
        toastStream: ctrl.stream,
      );

      await _pump(tester, child: w);
      ctrl.add('hola string');
      await tester.pump(const Duration(milliseconds: 30));

      expect(find.text('hola string'), findsOneWidget);

      // Semantics: existe un nodo con label 'Notification'
      expect(find.bySemanticsLabel('Notification'), findsWidgets);

      await ctrl.close();
    });
  });
}
