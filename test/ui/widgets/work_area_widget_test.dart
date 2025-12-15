import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// --------- Fake BlocResponsive (mismo de antes) ---------
class FakeBlocResponsive extends BlocResponsive {
  FakeBlocResponsive({
    required ScreenSizeEnum deviceType,
    required Size workArea,
    required int columnsNumber,
    required double marginWidth,
    double? gutterWidth,
  })  : _deviceType = deviceType,
        _workArea = workArea,
        _columns = columnsNumber,
        _margin = marginWidth,
        _gutterOverride = gutterWidth,
        super();

  final ScreenSizeEnum _deviceType;
  final Size _workArea;
  final int _columns;
  final double _margin;
  final double? _gutterOverride;

  bool setFromCtxCalled = false;

  @override
  void setSizeFromContext(BuildContext context) {}

  @override
  ScreenSizeEnum get deviceType => _deviceType;

  @override
  int get columnsNumber => _columns;

  @override
  double get marginWidth => _margin;

  @override
  Size get workAreaSize => _workArea;

  @override
  double get gutterWidth =>
      (_gutterOverride ?? ((marginWidth * 2) / columnsNumber)).floorToDouble();

  double get _columnWidth {
    double tmp = workAreaSize.width;
    tmp = tmp - (marginWidth * 2);
    tmp = tmp - (numberOfGutters(columnsNumber) * gutterWidth);
    tmp = tmp / columnsNumber;
    return tmp.clamp(0.0, double.maxFinite).floorToDouble();
  }

  @override
  double widthByColumns(int numberOfColumns) {
    final int cols = numberOfColumns.abs().clamp(1, columnsNumber);
    double w = _columnWidth * cols;
    if (cols > 1) {
      w += gutterWidth * (cols - 1);
    }
    return w;
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
        child: Material(child: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Regla de cómputo alineada al widget:
/// - base = gridW = (workArea.width - 2*margin)
/// - gaps: 1 si hay un panel, 2 si hay dos, 0 si no hay paneles
/// - ancho contenido = remaining = gridW - primaryW - secondaryW - usedGutters
/// - clampMin320: si true, se respeta 320 **solo si cabe** (si no, se usa remaining)
double expectedContentWidth({
  required BlocResponsive resp,
  required bool hasPrimary,
  required bool hasSecondary,
  required int primaryCols,
  required int secondaryCols,
  bool clampMin320 = false,
}) {
  final double maxW = resp.workAreaSize.width;
  final double mh = resp.marginWidth;
  final double gridW = (maxW - (mh * 2)).clamp(0.0, maxW);

  final double gap = resp.gutterWidth;

  final double primaryW = hasPrimary ? resp.widthByColumns(primaryCols) : 0.0;
  final double secondaryW =
      hasSecondary ? resp.widthByColumns(secondaryCols) : 0.0;

  // 1 gap si hay 1 panel; 2 gaps si hay 2 paneles; 0 si no hay paneles
  final int guttersCount =
      <bool>[hasPrimary, hasSecondary].where((bool v) => v).length;
  final double usedGutters = guttersCount > 0 ? gap * guttersCount : 0.0;

  final double remaining =
      (gridW - primaryW - secondaryW - usedGutters).clamp(0.0, gridW);

  if (!clampMin320) {
    return remaining;
  }

  // Respetar mínimo 320 sólo si cabe
  const double minTarget = 320.0;
  return remaining >= minTarget ? minTarget : remaining;
}

/// Contenido “neutro”: ancho finito pequeño para no overflow.
Widget _contentTight({Key? key, double width = 40, double height = 40}) =>
    SizedBox(
      key: key,
      width: width,
      height: height,
      child: const ColoredBox(color: Colors.transparent),
    );

/// Contenido que “pide” MUCHO ancho para validar que el ConstrainedBox/SizedBox lo
/// limite al valor calculado por el widget.
Widget _contentHuge({Key? key, double height = 40}) => SizedBox(
      key: key,
      width:
          5000, // demanda irreal: debe ser recortado por el layout del widget
      height: height,
      child: const ColoredBox(color: Colors.transparent),
    );

Widget _menuBox({Key? key, double height = 40}) => SizedBox(
      key: key,
      height: height,
      child: const ColoredBox(color: Colors.transparent),
    );

void main() {
  group('WorkAreaWidget - Mobile', () {
    testWidgets(
        'contenido solo, SafeArea por defecto y setSizeFromContext() llamado',
        (WidgetTester tester) async {
      final FakeBlocResponsive resp = FakeBlocResponsive(
        deviceType: ScreenSizeEnum.mobile,
        workArea: const Size(360, 640),
        columnsNumber: 4,
        marginWidth: 16,
        gutterWidth: 10,
      );

      final WorkAreaWidget w = WorkAreaWidget(
        responsive: resp,
        content: _contentTight(key: const ValueKey<String>('content')),
      );

      await _pump(tester, child: w);

      expect(find.byType(SafeArea), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('secondary-menu')),
        findsNothing,
      );
    });

    testWidgets('con secondaryMenu => overlay en bottom-center',
        (WidgetTester tester) async {
      final FakeBlocResponsive resp = FakeBlocResponsive(
        deviceType: ScreenSizeEnum.mobile,
        workArea: const Size(390, 780),
        columnsNumber: 4,
        marginWidth: 16,
        gutterWidth: 12,
      );

      final WorkAreaWidget w = WorkAreaWidget(
        responsive: resp,
        content: _contentTight(),
        secondaryMenu: _menuBox(key: const ValueKey<String>('secMobile')),
      );

      await _pump(tester, child: w);
      expect(find.byKey(const ValueKey<String>('secMobile')), findsOneWidget);
    });

    testWidgets('FAB: right=marginWidth, bottom=clamp(gutter*3, 48..96)',
        (WidgetTester tester) async {
      final FakeBlocResponsive resp = FakeBlocResponsive(
        deviceType: ScreenSizeEnum.mobile,
        workArea: const Size(400, 700),
        columnsNumber: 4,
        marginWidth: 20,
        gutterWidth: 10, // 10*3=30 -> clamp => 48
      );

      const ValueKey<String> fabKey = ValueKey<String>('fab');
      final WorkAreaWidget w = WorkAreaWidget(
        responsive: resp,
        content: _contentTight(),
        floatingActionButton: FloatingActionButton(
          key: fabKey,
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
      );

      await _pump(tester, child: w, surface: const Size(400, 700));

      // El MaterialApp llena toda la superficie.
      final Size screen = tester.getSize(find.byType(MaterialApp));
      final Rect r = tester.getRect(find.byKey(fabKey));

      final double rightGap = screen.width - (r.left + r.width);
      expect(rightGap, resp.marginWidth);

      final double expectedBottom = (resp.gutterWidth * 3).clamp(48.0, 96.0);
      final double bottomGap = screen.height - (r.top + r.height);
      expect(bottomGap, expectedBottom);
    });

    testWidgets('backgroundColor custom y safeArea=false',
        (WidgetTester tester) async {
      final FakeBlocResponsive resp = FakeBlocResponsive(
        deviceType: ScreenSizeEnum.mobile,
        workArea: const Size(360, 640),
        columnsNumber: 4,
        marginWidth: 16,
        gutterWidth: 12,
      );

      const MaterialColor bg = Colors.orange;
      final WorkAreaWidget w = WorkAreaWidget(
        responsive: resp,
        content: _contentTight(),
        safeArea: false,
        backgroundColor: bg,
      );

      await _pump(tester, child: w);
      expect(find.byType(SafeArea), findsNothing);

      final Container c = tester.widget(find.byType(Container).first);
      expect(c.color, bg);
    });
  });

  group('WorkAreaWidget - Tablet/Desktop/TV', () {
    testWidgets('tablet: primary+content+secondary, anchos y orden por defecto',
        (WidgetTester tester) async {
      // workArea=720, columns=12, margin=16, gutter=10
      final FakeBlocResponsive resp = FakeBlocResponsive(
        deviceType: ScreenSizeEnum.tablet,
        workArea: const Size(720, 900),
        columnsNumber: 12,
        marginWidth: 16,
        gutterWidth: 10,
      );

      const int pCols = 2, sCols = 2;
      final double primaryW = resp.widthByColumns(pCols);
      final double secondaryW = resp.widthByColumns(sCols);
      final double expectedW = expectedContentWidth(
        resp: resp,
        hasPrimary: true,
        hasSecondary: true,
        primaryCols: pCols,
        secondaryCols: sCols,
      );

      final WorkAreaWidget w = WorkAreaWidget(
        responsive: resp,
        // Le pedimos MUCHO ancho para validar que el layout lo recorta:
        content: _contentHuge(key: const ValueKey<String>('content')),
        primaryMenu: _menuBox(key: const ValueKey<String>('primary')),
        secondaryMenu: _menuBox(key: const ValueKey<String>('secondary')),
      );

      // Surface >= workArea para no “tocar techo”
      await _pump(tester, child: w, surface: const Size(1000, 900));

      expect(
        tester.getSize(find.byKey(const ValueKey<String>('primary'))).width,
        primaryW,
      );
      expect(
        tester.getSize(find.byKey(const ValueKey<String>('secondary'))).width,
        secondaryW,
      );
      expect(
        tester.getSize(find.byKey(const ValueKey<String>('content'))).width,
        expectedW,
      );

      final double dxP =
          tester.getTopLeft(find.byKey(const ValueKey<String>('primary'))).dx;
      final double dxC =
          tester.getTopLeft(find.byKey(const ValueKey<String>('content'))).dx;
      final double dxS =
          tester.getTopLeft(find.byKey(const ValueKey<String>('secondary'))).dx;
      expect(dxP < dxC, isTrue);
      expect(dxC < dxS, isTrue);
    });

    testWidgets('tablet: secondaryOnRight=false invierte el orden relativo',
        (WidgetTester tester) async {
      final FakeBlocResponsive resp = FakeBlocResponsive(
        deviceType: ScreenSizeEnum.tablet,
        workArea: const Size(720, 900),
        columnsNumber: 12,
        marginWidth: 16,
        gutterWidth: 10,
      );

      // Para centrarnos en el orden, que el content no empuje:
      final WorkAreaWidget w = WorkAreaWidget(
        responsive: resp,
        content:
            _contentTight(key: const ValueKey<String>('content'), width: 200),
        primaryMenu: _menuBox(key: const ValueKey<String>('primary')),
        secondaryMenu: _menuBox(key: const ValueKey<String>('secondary')),
        secondaryMenuOnRight: false,
      );

      await _pump(tester, child: w, surface: const Size(1000, 900));

      final double dxP =
          tester.getTopLeft(find.byKey(const ValueKey<String>('primary'))).dx;
      final double dxC =
          tester.getTopLeft(find.byKey(const ValueKey<String>('content'))).dx;
      final double dxS =
          tester.getTopLeft(find.byKey(const ValueKey<String>('secondary'))).dx;
      expect(dxS < dxC, isTrue);
      expect(dxC < dxP, isTrue);
    });

    testWidgets(
        'desktop: sólo primary => contentW = gridW - primary - gap (>=320 si cabe)',
        (WidgetTester tester) async {
      final FakeBlocResponsive resp = FakeBlocResponsive(
        deviceType: ScreenSizeEnum.desktop,
        workArea: const Size(900, 800),
        columnsNumber: 9,
        marginWidth: 16,
        gutterWidth: 12,
      );

      const int pCols = 3;
      final double expectedW = expectedContentWidth(
        resp: resp,
        hasPrimary: true,
        hasSecondary: false,
        primaryCols: pCols, // <- corregido (antes 2)
        secondaryCols: 0,
        clampMin320: true,
      );

      final WorkAreaWidget w = WorkAreaWidget(
        responsive: resp,
        content: _contentHuge(key: const ValueKey<String>('content')),
        primaryMenu: _menuBox(),
        primaryMenuWidthColumns: pCols,
      );

      // Surface >= workArea
      await _pump(tester, child: w, surface: const Size(1200, 800));
      expect(
        tester.getSize(find.byKey(const ValueKey<String>('content'))).width,
        expectedW,
      );
    });

    testWidgets(
        'desktop: sólo secondary => contentW = gridW - secondary - gap (>=320 si cabe)',
        (WidgetTester tester) async {
      final FakeBlocResponsive resp = FakeBlocResponsive(
        deviceType: ScreenSizeEnum.desktop,
        workArea: const Size(900, 800),
        columnsNumber: 9,
        marginWidth: 16,
        gutterWidth: 12,
      );

      const int sCols = 3;
      final double expectedW = expectedContentWidth(
        resp: resp,
        hasPrimary: false,
        hasSecondary: true,
        primaryCols: 0,
        secondaryCols: sCols,
        clampMin320: true,
      );

      final WorkAreaWidget w = WorkAreaWidget(
        responsive: resp,
        content: _contentHuge(key: const ValueKey<String>('content')),
        secondaryMenu: _menuBox(),
        secondaryMenuWidthColumns: sCols,
      );

      await _pump(tester, child: w, surface: const Size(1200, 800));
      expect(
        tester.getSize(find.byKey(const ValueKey<String>('content'))).width,
        expectedW,
      );
    });

    testWidgets('desktop: sin menús => contentW = gridW (sin clamp)',
        (WidgetTester tester) async {
      final FakeBlocResponsive resp = FakeBlocResponsive(
        deviceType: ScreenSizeEnum.desktop,
        workArea: const Size(1024, 800),
        columnsNumber: 12,
        marginWidth: 16,
        gutterWidth: 10,
      );

      final double expectedW = expectedContentWidth(
        resp: resp,
        hasPrimary: false,
        hasSecondary: false,
        primaryCols: 0,
        secondaryCols: 0,
      );

      final WorkAreaWidget w = WorkAreaWidget(
        responsive: resp,
        content: _contentHuge(key: const ValueKey<String>('content')),
      );

      await _pump(tester, child: w, surface: const Size(1400, 800));
      expect(
        tester.getSize(find.byKey(const ValueKey<String>('content'))).width,
        expectedW,
      );
    });

    testWidgets(
        'desktop: clamp a 320 cuando el resto deja < 320 (sin overflow)',
        (WidgetTester tester) async {
      final FakeBlocResponsive resp = FakeBlocResponsive(
        deviceType: ScreenSizeEnum.desktop,
        workArea: const Size(400, 700),
        columnsNumber: 6,
        marginWidth: 16,
        gutterWidth: 8,
      );

      // Defaults del widget: primary=2 cols, secondary=2 cols
      final double expectedW = expectedContentWidth(
        resp: resp,
        hasPrimary: true,
        hasSecondary: true,
        primaryCols: 2,
        secondaryCols: 2,
        clampMin320: true, // => 320 sólo si cabe, si no: remaining
      );

      final WorkAreaWidget w = WorkAreaWidget(
        responsive: resp,
        content: _contentHuge(key: const ValueKey<String>('content')),
        primaryMenu: _menuBox(),
        secondaryMenu: _menuBox(),
      );

      await _pump(tester, child: w, surface: const Size(800, 700));
      expect(
        tester.getSize(find.byKey(const ValueKey<String>('content'))).width,
        expectedW,
      );
    });

    testWidgets('TV: mismo que desktop y FAB en esquina con margen',
        (WidgetTester tester) async {
      final FakeBlocResponsive resp = FakeBlocResponsive(
        deviceType: ScreenSizeEnum.tv,
        workArea: const Size(1280, 800),
        columnsNumber: 12,
        marginWidth: 24,
        gutterWidth: 12,
      );

      const ValueKey<String> fabKey = ValueKey<String>('fabTv');
      final WorkAreaWidget w = WorkAreaWidget(
        responsive: resp,
        content: _contentHuge(key: const ValueKey<String>('content')),
        secondaryMenu: _menuBox(),
        secondaryMenuWidthColumns: 3,
        floatingActionButton: FloatingActionButton(
          key: fabKey,
          onPressed: () {},
          child: const Icon(Icons.adb),
        ),
      );

      await _pump(tester, child: w, surface: const Size(1400, 900));

      final Size screen = tester.getSize(find.byType(MaterialApp));
      final Rect r = tester.getRect(find.byKey(fabKey));

      final double rightGap = screen.width - (r.left + r.width);
      final double bottomGap = screen.height - (r.top + r.height);
      expect(rightGap, resp.marginWidth);
      expect(bottomGap, resp.marginWidth);
    });

    testWidgets('backgroundColor custom y safeArea=false (desktop)',
        (WidgetTester tester) async {
      final FakeBlocResponsive resp = FakeBlocResponsive(
        deviceType: ScreenSizeEnum.desktop,
        workArea: const Size(1024, 800),
        columnsNumber: 12,
        marginWidth: 16,
        gutterWidth: 10,
      );

      const MaterialColor bg = Colors.teal;
      final WorkAreaWidget w = WorkAreaWidget(
        responsive: resp,
        content: _contentTight(width: 200),
        secondaryMenu: _menuBox(),
        safeArea: false,
        backgroundColor: bg,
      );

      await _pump(tester, child: w, surface: const Size(1400, 800));
      expect(find.byType(SafeArea), findsNothing);

      final Container root = tester.widget(find.byType(Container).first);
      expect(root.color, bg);
    });
  });
}
