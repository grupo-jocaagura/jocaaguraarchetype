import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

// ---------------- Fake BlocResponsive (minimal para botones) ----------------
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

// ---------------- Helpers ----------------
Future<void> _pump(
  WidgetTester tester, {
  required Widget child,
  Size surface = const Size(800, 600),
  ThemeData? theme,
  double? hostWidth, // null => no SizedBox para evitar "tight" si no se desea
  bool settle = true, // false => evita timeouts con animaciones infinitas
}) async {
  final Widget host =
      (hostWidth == null) ? child : SizedBox(width: hostWidth, child: child);

  await tester.pumpWidget(
    MaterialApp(
      theme: theme ?? ThemeData(useMaterial3: true),
      home: MediaQuery(
        data: MediaQueryData(size: surface),
        child: Scaffold(
          body: Center(child: host),
        ),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    // Un frame es suficiente cuando hay animación indeterminada (spinner).
    await tester.pump(const Duration(milliseconds: 16));
  }
}

// Recalcula tokens esperados (misma lógica que _resolveSizeTokens)
class _Tokens {
  const _Tokens(this.minH, this.minW);
  final double minH;
  final double minW;
}

_Tokens _expectedTokens(FakeBlocResponsive r, AppButtonSize size) {
  final double cw = r.columnWidth;
  switch (size) {
    case AppButtonSize.small:
      return _Tokens(
        (cw * 0.70).clamp(36.0, 40.0),
        (r.widthByColumns(2) * 0.6).clamp(80.0, 140.0),
      );
    case AppButtonSize.medium:
      return _Tokens(
        (cw * 0.85).clamp(40.0, 48.0),
        (r.widthByColumns(2) * 0.8).clamp(120.0, 200.0),
      );
    case AppButtonSize.large:
      return _Tokens(
        (cw * 1.10).clamp(48.0, 56.0),
        (r.widthByColumns(3) * 0.8).clamp(160.0, 280.0),
      );
  }
}

void main() {
  group('MyAppButtonWidget - variantes y estados', () {
    testWidgets(
        'filled enabled: dispara onPressed y hay Semantics con label por defecto',
        (WidgetTester tester) async {
      final FakeBlocResponsive resp = FakeBlocResponsive(
        deviceType: ScreenSizeEnum.desktop,
        workAreaSize: const Size(960, 600),
        columnsNumber: 12,
        marginWidth: 16,
        gutterWidth: 10,
      );

      int taps = 0;
      final MyAppButtonWidget w = MyAppButtonWidget(
        key: const ValueKey<String>('btn'),
        responsive: resp,
        label: 'Guardar',
        onPressed: () => taps++,
      );

      await _pump(tester, child: w);

      expect(find.byType(FilledButton), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey<String>('btn')));
      await tester.pumpAndSettle();
      expect(taps, 1);

      // setSizeFromContext() se llamó
      expect(resp.setFromCtxCalled, isTrue);

      // Puede haber más de un nodo Semantics (fusión). Verificamos que exista alguno.
      expect(find.bySemanticsLabel('Guardar'), findsWidgets);
    });

    testWidgets('tonal/outlined/text: construyen el tipo correcto',
        (WidgetTester tester) async {
      final FakeBlocResponsive resp = FakeBlocResponsive(
        deviceType: ScreenSizeEnum.tablet,
        workAreaSize: const Size(720, 600),
        columnsNumber: 12,
        marginWidth: 16,
        gutterWidth: 10,
      );

      await _pump(
        tester,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            MyAppButtonWidget(
              responsive: resp,
              label: 'Tonal',
              onPressed: () {},
              variant: AppButtonVariant.tonal,
            ),
            MyAppButtonWidget(
              responsive: resp,
              label: 'Outlined',
              onPressed: () {},
              variant: AppButtonVariant.outlined,
            ),
            MyAppButtonWidget(
              responsive: resp,
              label: 'Text',
              onPressed: () {},
              variant: AppButtonVariant.text,
            ),
          ],
        ),
      );

      expect(
        find.byType(FilledButton),
        findsOneWidget,
      ); // tonal => FilledButton.tonal
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('disabled: enabled=false anula onPressed',
        (WidgetTester tester) async {
      final FakeBlocResponsive resp = FakeBlocResponsive(
        deviceType: ScreenSizeEnum.desktop,
        workAreaSize: const Size(900, 600),
        columnsNumber: 12,
        marginWidth: 16,
        gutterWidth: 10,
      );

      int taps = 0;
      final MyAppButtonWidget w = MyAppButtonWidget(
        responsive: resp,
        label: 'Off',
        enabled: false,
        onPressed: () => taps++,
      );

      await _pump(tester, child: w);
      final FilledButton btn = tester.widget(find.byType(FilledButton));
      expect(btn.onPressed, isNull);

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(taps, 0);
    });

    testWidgets('loading: muestra spinner y no permite taps',
        (WidgetTester tester) async {
      final FakeBlocResponsive resp = FakeBlocResponsive(
        deviceType: ScreenSizeEnum.desktop,
        workAreaSize: const Size(900, 600),
        columnsNumber: 12,
        marginWidth: 16,
        gutterWidth: 10,
      );

      int taps = 0;
      final MyAppButtonWidget w = MyAppButtonWidget(
        responsive: resp,
        label: 'Procesando',
        loading: true,
        onPressed: () => taps++,
      );

      // NOTA: settle=false para no esperar a que cese la animación indeterminada
      await _pump(tester, child: w, settle: false);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      final FilledButton btn = tester.widget(find.byType(FilledButton));
      expect(btn.onPressed, isNull);

      await tester.tap(find.byType(FilledButton));
      await tester.pump(const Duration(milliseconds: 50));
      expect(taps, 0);

      // Existe Semantics con el label (el "value: Loading" no lo validamos aquí).
      expect(find.bySemanticsLabel('Procesando'), findsWidgets);
    });
  });

  group('MyAppButtonWidget - sizing responsivo', () {
    testWidgets(
        'small/medium/large: respetan minHeight y minWidth (constraints)',
        (WidgetTester tester) async {
      final FakeBlocResponsive resp = FakeBlocResponsive(
        deviceType: ScreenSizeEnum.desktop,
        workAreaSize: const Size(960, 600),
        columnsNumber: 12,
        marginWidth: 16,
        gutterWidth: 10,
      );

      final Column w = Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          MyAppButtonWidget(
            key: const ValueKey<String>('s'),
            responsive: resp,
            size: AppButtonSize.small,
            label: 'S',
            onPressed: () {},
          ),
          MyAppButtonWidget(
            key: const ValueKey<String>('m'),
            responsive: resp,
            label: 'M',
            onPressed: () {},
          ),
          MyAppButtonWidget(
            key: const ValueKey<String>('l'),
            responsive: resp,
            size: AppButtonSize.large,
            label: 'L',
            onPressed: () {},
          ),
        ],
      );

      await _pump(tester, child: w, hostWidth: 500);

      for (final MapEntry<String, AppButtonSize> entry
          in <String, AppButtonSize>{
        's': AppButtonSize.small,
        'm': AppButtonSize.medium,
        'l': AppButtonSize.large,
      }.entries) {
        final Size sz = tester.getSize(find.byKey(ValueKey<String>(entry.key)));
        final _Tokens tk = _expectedTokens(resp, entry.value);
        expect(sz.height >= tk.minH, isTrue, reason: '${entry.key} minHeight');
        expect(sz.width >= tk.minW, isTrue, reason: '${entry.key} minWidth');
      }
    });

    testWidgets('fullWidth=true ocupa todo el ancho disponible del host',
        (WidgetTester tester) async {
      final FakeBlocResponsive resp = FakeBlocResponsive(
        deviceType: ScreenSizeEnum.tablet,
        workAreaSize: const Size(720, 600),
        columnsNumber: 12,
        marginWidth: 16,
        gutterWidth: 10,
      );

      const double hostW = 640;
      final MyAppButtonWidget w = MyAppButtonWidget(
        key: const ValueKey<String>('fw'),
        responsive: resp,
        label: 'Full',
        fullWidth: true,
        onPressed: () {},
      );

      await _pump(tester, child: w, hostWidth: hostW);
      final Size sz = tester.getSize(find.byKey(const ValueKey<String>('fw')));
      expect(sz.width, hostW);
    });

    testWidgets('maxWidthColumns limita el ancho incluso con fullWidth=true',
        (WidgetTester tester) async {
      final FakeBlocResponsive resp = FakeBlocResponsive(
        deviceType: ScreenSizeEnum.desktop,
        workAreaSize: const Size(1200, 700),
        columnsNumber: 12,
        marginWidth: 16,
        gutterWidth: 10,
      );

      const int maxCols = 3;
      final double expectedMax = resp.widthByColumns(maxCols); // p.ej. 284

      final MyAppButtonWidget w = MyAppButtonWidget(
        key: const ValueKey<String>('mx'),
        responsive: resp,
        label: 'Max',
        fullWidth: true,
        maxWidthColumns: maxCols,
        onPressed: () {},
      );

      // Importante: hostWidth=null para NO forzar ancho "tight" que anule la ConstrainedBox.
      await _pump(tester, child: w);

      final Size sz = tester.getSize(find.byKey(const ValueKey<String>('mx')));
      expect(sz.width, expectedMax);
    });
  });

  group('MyAppButtonWidget - leading/trailing, tooltip y semántica', () {
    testWidgets('leading/trailing: Sin widget personalizado dibuja icono',
        (WidgetTester tester) async {
      final FakeBlocResponsive resp = FakeBlocResponsive(
        deviceType: ScreenSizeEnum.desktop,
        workAreaSize: const Size(900, 600),
        columnsNumber: 12,
        marginWidth: 16,
        gutterWidth: 10,
      );

      final MyAppButtonWidget w = MyAppButtonWidget(
        responsive: resp,
        label: 'Acción',
        onPressed: () {},
        leadingIcon: Icons.add,
        trailingIcon: Icons.check,
      );

      await _pump(tester, child: w);

      expect(find.byIcon(Icons.add), findsAtLeast(1));
      expect(find.byIcon(Icons.check), findsOne);
    });

    testWidgets(
        'leading/trailing: widget personalizado tiene prioridad sobre icono',
        (WidgetTester tester) async {
      final FakeBlocResponsive resp = FakeBlocResponsive(
        deviceType: ScreenSizeEnum.desktop,
        workAreaSize: const Size(900, 600),
        columnsNumber: 12,
        marginWidth: 16,
        gutterWidth: 10,
      );

      final MyAppButtonWidget w = MyAppButtonWidget(
        responsive: resp,
        label: 'Acción',
        onPressed: () {},
        leadingIcon: Icons.add, // NO debería mostrarse
        trailingIcon: Icons.check, // NO debería mostrarse
        leading: const SizedBox(
          key: ValueKey<String>('lead'),
          width: 10,
          height: 10,
        ),
        trailing: const SizedBox(
          key: ValueKey<String>('trail'),
          width: 10,
          height: 10,
        ),
      );

      await _pump(tester, child: w);

      expect(find.byKey(const ValueKey<String>('lead')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('trail')), findsOneWidget);
      expect(find.byIcon(Icons.add), findsNothing);
      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('tooltip y semanticsLabel personalizados',
        (WidgetTester tester) async {
      final FakeBlocResponsive resp = FakeBlocResponsive(
        deviceType: ScreenSizeEnum.tablet,
        workAreaSize: const Size(720, 600),
        columnsNumber: 12,
        marginWidth: 16,
        gutterWidth: 10,
      );

      final MyAppButtonWidget w = MyAppButtonWidget(
        responsive: resp,
        label: 'Default',
        semanticsLabel: 'SemLabel',
        tooltip: 'Ayuda',
        onPressed: () {},
      );

      await _pump(tester, child: w);

      final Tooltip tip = tester.widget(find.byType(Tooltip));
      expect(tip.message, 'Ayuda');

      expect(find.bySemanticsLabel('SemLabel'), findsWidgets);
    });
  });
}
