import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// --------- Fake BlocResponsive ---------
/// Controla deviceType, columnas, márgenes y área de trabajo.
/// Implementa los getters usados por el widget y calcula widthByColumns
/// como en BlocResponsive (basado en columnWidth + gutters).
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
  void setSizeFromContext(BuildContext context) {
    // Solo marcamos que fue invocado (no alteramos métricas).
    setFromCtxCalled = true;
  }

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
      (_gutterOverride ?? ((marginWidth * 2) / columnsNumber))
          .floorToDouble();

  double get _columnWidth {
    // Implementación alineada a BlocResponsive:
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

Widget _contentBox({Key? key, double height = 40}) =>
    // Ancho infinito para respetar el maxWidth del ConstrainedBox.
SizedBox(key: key, width: double.infinity, height: height, child: const ColoredBox(color: Colors.transparent));

Widget _panelBox({Key? key, double height = 40}) =>
    SizedBox(key: key, height: height, child: const ColoredBox(color: Colors.transparent));

void main() {
  group('PageWithSecondaryMenuWidget - mobile overlay', () {
    testWidgets('sin secondaryMenu => no overlay, usa SafeArea y setSizeFromContext() se invoca',
            (WidgetTester tester) async {
          final FakeBlocResponsive resp = FakeBlocResponsive(
            deviceType: ScreenSizeEnum.mobile,
            workArea: const Size(360, 640),
            columnsNumber: 4,
            marginWidth: 16,
            gutterWidth: 10, // se usará clamp(8..16) internamente
          );

          final Widget w = PageWithSecondaryMenuWidget(
            responsive: resp,
            content: _contentBox(key: const ValueKey<String>('content')),
          );

          await _pump(tester, child: w);

          // SafeArea presente por defecto
          expect(find.byType(SafeArea), findsOneWidget);

          // No hay AnimatedSwitcher del overlay móvil
          expect(find.byKey(const ValueKey<String>('mobile-secondary')), findsNothing);

          // Se sincronizan métricas con el contexto
          expect(resp.setFromCtxCalled, isTrue);
        });

    testWidgets('con secondaryMenu animate=true => aparece overlay con key "mobile-secondary"',
            (WidgetTester tester) async {
          final FakeBlocResponsive resp = FakeBlocResponsive(
            deviceType: ScreenSizeEnum.mobile,
            workArea: const Size(390, 780),
            columnsNumber: 4,
            marginWidth: 16,
            gutterWidth: 14, // dentro del clamp (8..16)
          );

          final Widget w = PageWithSecondaryMenuWidget(
            responsive: resp,
            content: _contentBox(),
            secondaryMenu: _panelBox(key: const ValueKey<String>('mobileMenu')),
            // animate true por defecto
          );

          await _pump(tester, child: w);

          expect(find.byKey(const ValueKey<String>('mobile-secondary')), findsOneWidget);
          // Y el contenido está en el árbol
          expect(find.byKey(const ValueKey<String>('mobileMenu')), findsOneWidget);
        });

    testWidgets('con secondaryMenu animate=false => no AnimatedSwitcher',
            (WidgetTester tester) async {
          final FakeBlocResponsive resp = FakeBlocResponsive(
            deviceType: ScreenSizeEnum.mobile,
            workArea: const Size(390, 780),
            columnsNumber: 4,
            marginWidth: 20,
            gutterWidth: 22, // clamp interno a 16 para el padding, no afecta a esta aserción
          );

          final Widget w = PageWithSecondaryMenuWidget(
            responsive: resp,
            content: _contentBox(),
            secondaryMenu: _panelBox(key: const ValueKey<String>('menuNoAnim')),
            animate: false,
          );

          await _pump(tester, child: w);
          // No existe el key del AnimatedSwitcher
          expect(find.byKey(const ValueKey<String>('mobile-secondary')), findsNothing);
          expect(find.byKey(const ValueKey<String>('menuNoAnim')), findsOneWidget);
        });

    testWidgets('backgroundColor custom se aplica en mobile',
            (WidgetTester tester) async {
          final FakeBlocResponsive resp = FakeBlocResponsive(
            deviceType: ScreenSizeEnum.mobile,
            workArea: const Size(400, 700),
            columnsNumber: 4,
            marginWidth: 24,
            gutterWidth: 12,
          );

          const Color bg = Colors.pink;
          final Widget w = PageWithSecondaryMenuWidget(
            responsive: resp,
            content: _contentBox(),
            backgroundColor: bg,
          );

          await _pump(tester, child: w);
          // El primer Container del body móvil usa color de fondo
          final Container container = tester.widget(find.byType(Container).first);
          expect(container.color, bg);
        });

    testWidgets('safeArea=false => no envuelve con SafeArea',
            (WidgetTester tester) async {
          final FakeBlocResponsive resp = FakeBlocResponsive(
            deviceType: ScreenSizeEnum.mobile,
            workArea: const Size(400, 700),
            columnsNumber: 4,
            marginWidth: 24,
            gutterWidth: 12,
          );

          final Widget w = PageWithSecondaryMenuWidget(
            responsive: resp,
            content: _contentBox(),
            safeArea: false,
          );

          await _pump(tester, child: w);
          expect(find.byType(SafeArea), findsNothing);
        });
  });

  group('PageWithSecondaryMenuWidget - tablet/desktop/TV side panel', () {
    testWidgets('tablet con panel a la derecha: anchos esperados y AnimatedSwitcher con key',
            (WidgetTester tester) async {
          // Métricas elegidas para números redondos:
          // workArea=720, columns=12, margin=16, gutter=10
          // columnW = floor((720 - 32 - 11*10) / 12) = floor((720-142)/12)=floor(578/12)=48
          // widthByColumns(2) = 48*2 + 10 = 106
          final FakeBlocResponsive resp = FakeBlocResponsive(
            deviceType: ScreenSizeEnum.tablet,
            workArea: const Size(720, 900),
            columnsNumber: 12,
            marginWidth: 16,
            gutterWidth: 10,
          );

          const int panelCols = 2;
          final double panelW = resp.widthByColumns(panelCols);
          final double gap = resp.gutterWidth;
          final double contentW = (resp.workAreaSize.width - panelW - gap)
              .clamp(360.0, resp.workAreaSize.width);

          final Widget w = PageWithSecondaryMenuWidget(
            responsive: resp,
            content: _contentBox(key: const ValueKey<String>('content')),
            secondaryMenu: _panelBox(key: const ValueKey<String>('panelChild')),
            // secondaryOnRight = true (default)
          );

          await _pump(tester, child: w);

          // Panel envuelto en AnimatedSwitcher con key 'panel-secondary'
          expect(find.byKey(const ValueKey<String>('panel-secondary')), findsOneWidget);

          // El ancho del panel coincide con widthByColumns(panelColumns)
          expect(
            tester.getSize(find.byKey(const ValueKey<String>('panelChild'))).width,
            panelW,
          );

          // El contenido está limitado por maxWidth = contentW
          expect(
            tester.getSize(find.byKey(const ValueKey<String>('content'))).width,
            contentW,
          );

          // Orden: content a la izquierda, panel a la derecha
          final double dxContent =
              tester.getTopLeft(find.byKey(const ValueKey<String>('content'))).dx;
          final double dxPanel =
              tester.getTopLeft(find.byKey(const ValueKey<String>('panelChild'))).dx;
          expect(dxContent < dxPanel, isTrue);
        });

    testWidgets('tablet con panel a la izquierda (secondaryOnRight=false)',
            (WidgetTester tester) async {
          final FakeBlocResponsive resp = FakeBlocResponsive(
            deviceType: ScreenSizeEnum.tablet,
            workArea: const Size(720, 900),
            columnsNumber: 12,
            marginWidth: 16,
            gutterWidth: 10,
          );

          final Widget w = PageWithSecondaryMenuWidget(
            responsive: resp,
            content: _contentBox(key: const ValueKey<String>('content')),
            secondaryMenu: _panelBox(key: const ValueKey<String>('panelChild')),
            secondaryOnRight: false,
          );

          await _pump(tester, child: w);

          final double dxContent =
              tester.getTopLeft(find.byKey(const ValueKey<String>('content'))).dx;
          final double dxPanel =
              tester.getTopLeft(find.byKey(const ValueKey<String>('panelChild'))).dx;

          // Ahora el panel debe quedar más a la izquierda que el contenido
          expect(dxPanel < dxContent, isTrue);
        });

    testWidgets('desktop: clamp a 360 cuando (maxW - panel - gap) < 360',
            (WidgetTester tester) async {
          // workArea "estrecha" para forzar el clamp.
          // Elegimos métricas que produzcan contentW crudo < 360.
          final FakeBlocResponsive resp = FakeBlocResponsive(
            deviceType: ScreenSizeEnum.desktop,
            workArea: const Size(400, 900),
            columnsNumber: 6,
            marginWidth: 16,
            gutterWidth: 8,
          );

          // columnW = floor((400 - 32 - 5*8)/6) = floor((400-72)/6)=floor(328/6)=54
          // panel (2 cols) = 54*2 + 8 = 116
          // contentW crudo = 400 - 116 - 8 = 276  => clamp -> 360
          final Widget w = PageWithSecondaryMenuWidget(
            responsive: resp,
            content: _contentBox(key: const ValueKey<String>('content')),
            secondaryMenu: _panelBox(),
          );

          await _pump(tester, child: w);

          expect(
            tester.getSize(find.byKey(const ValueKey<String>('content'))).width,
            360.0,
          );
        });

    testWidgets('TV usa la misma política de side panel que desktop',
            (WidgetTester tester) async {
          final FakeBlocResponsive resp = FakeBlocResponsive(
            deviceType: ScreenSizeEnum.tv,
            workArea: const Size(1280, 900),
            columnsNumber: 12,
            marginWidth: 24,
            gutterWidth: 12,
          );

          final Widget w = PageWithSecondaryMenuWidget(
            responsive: resp,
            content: _contentBox(key: const ValueKey<String>('content')),
            secondaryMenu: _panelBox(key: const ValueKey<String>('panelChild')),
            panelColumns: 3,
          );

          await _pump(tester, child: w);

          // Presencia de panel (AnimatedSwitcher con key)
          expect(find.byKey(const ValueKey<String>('panel-secondary')), findsOneWidget);
          // Ancho coherente
          final double expected = resp.widthByColumns(3);
          expect(
            tester.getSize(find.byKey(const ValueKey<String>('panelChild'))).width,
            expected,
          );
        });

    testWidgets('sin secondaryMenu => solo contenido, panelW=0, sin AnimatedSwitcher',
            (WidgetTester tester) async {
          final FakeBlocResponsive resp = FakeBlocResponsive(
            deviceType: ScreenSizeEnum.desktop,
            workArea: const Size(1024, 800),
            columnsNumber: 12,
            marginWidth: 16,
            gutterWidth: 10,
          );

          final Widget w = PageWithSecondaryMenuWidget(
            responsive: resp,
            content: _contentBox(key: const ValueKey<String>('content')),
          );

          await _pump(tester, child: w);

          expect(find.byKey(const ValueKey<String>('panel-secondary')), findsNothing);
          // El contenido usa el ancho máximo del workArea (limitado por padding del widget).
          // Aquí validamos simplemente que está en el árbol y no colapsa.
          expect(find.byKey(const ValueKey<String>('content')), findsOneWidget);
        });

    testWidgets('panelColumns > columnsNumber => clamp a columnsNumber',
            (WidgetTester tester) async {
          final FakeBlocResponsive resp = FakeBlocResponsive(
            deviceType: ScreenSizeEnum.tablet,
            workArea: const Size(720, 900),
            columnsNumber: 3, // pequeño para forzar el clamp
            marginWidth: 16,
            gutterWidth: 10,
          );

          // panelColumns=5 -> se clampa a 3
          final double expectedPanelW = resp.widthByColumns(resp.columnsNumber);

          final Widget w = PageWithSecondaryMenuWidget(
            responsive: resp,
            content: _contentBox(),
            secondaryMenu: _panelBox(key: const ValueKey<String>('panelChild')),
            panelColumns: 5,
          );

          await _pump(tester, child: w);

          expect(
            tester.getSize(find.byKey(const ValueKey<String>('panelChild'))).width,
            expectedPanelW,
          );
        });

    testWidgets('animate=false => el panel se pinta sin AnimatedSwitcher',
            (WidgetTester tester) async {
          final FakeBlocResponsive resp = FakeBlocResponsive(
            deviceType: ScreenSizeEnum.desktop,
            workArea: const Size(1200, 900),
            columnsNumber: 12,
            marginWidth: 20,
            gutterWidth: 12,
          );

          final Widget w = PageWithSecondaryMenuWidget(
            responsive: resp,
            content: _contentBox(),
            secondaryMenu: _panelBox(key: const ValueKey<String>('panelChild')),
            animate: false,
          );

          await _pump(tester, child: w);
          expect(find.byKey(const ValueKey<String>('panel-secondary')), findsNothing);
          expect(find.byKey(const ValueKey<String>('panelChild')), findsOneWidget);
        });

    testWidgets('backgroundColor custom en desktop/tablet',
            (WidgetTester tester) async {
          final FakeBlocResponsive resp = FakeBlocResponsive(
            deviceType: ScreenSizeEnum.desktop,
            workArea: const Size(1024, 800),
            columnsNumber: 12,
            marginWidth: 16,
            gutterWidth: 10,
          );

          const Color bg = Colors.teal;
          final Widget w = PageWithSecondaryMenuWidget(
            responsive: resp,
            content: _contentBox(),
            secondaryMenu: _panelBox(),
            backgroundColor: bg,
          );

          await _pump(tester, child: w);
          // El Container raíz del layout desktop/tablet lleva el color de fondo
          final Container root = tester.widget(find.byType(Container).first);
          expect(root.color, bg);
        });
  });
}
