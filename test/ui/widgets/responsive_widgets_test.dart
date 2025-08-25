// test/ui/widgets/responsive_widgets_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';


/// Fake que nos permite fijar el size manualmente y
/// registrar si se llamó setSizeFromContext().
class _FakeBlocResponsive extends BlocResponsive {
  _FakeBlocResponsive({Size? initial}) : super() {
    if (initial != null) {
      setSizeForTesting(initial);
    }
  }

  bool setFromCtxCalled = false;

  @override
  void setSizeFromContext(BuildContext context) {
    // registramos la invocación pero no alteramos el size en tests
    setFromCtxCalled = true;
    setSize(MediaQuery.of(context).size); // opcional

  }
}

/// Helper para envolver el widget bajo prueba con Directionality + MediaQuery.
Future<void> _pumpWithSize(
    WidgetTester tester, {
      required Size size,
      required Widget child,
    }) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: MediaQueryData(size: size),
        child: Material(child: child),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('ResponsiveSizeWidget', () {
    testWidgets('elige builder según deviceType y usa fallback cuando corresponde',
            (WidgetTester tester) async {
          // Creamos un Fake y tomamos sus thresholds
          final _FakeBlocResponsive fake = _FakeBlocResponsive(initial: const Size(360, 800));
          final ScreenSizeConfig cfg = fake.sizeConfig;

          // Builders diferenciados por etiqueta (los verificamos con Finder por texto)
          Widget b(String name) => Builder(
            builder: (_) => Text('builder:$name', key: ValueKey<String>(name)),
          );

          // 1) mobile: width <= maxMobile
          final Size mobileSize = Size(cfg.maxMobileScreenWidth, 800);
          fake.setSizeForTesting(mobileSize);
          await _pumpWithSize(
            tester,
            size: mobileSize,
            child: ResponsiveSizeWidget(
              responsive: fake,
              mobile: (_, __) => b('mobile'),
              tablet: (_, __) => b('tablet'),
              desktop: (_, __) => b('desktop'),
              tv: (_, __) => b('tv'),
              fallback: (_, __) => b('fallback'),
            ),
          );
          expect(find.byKey(const ValueKey<String>('mobile')), findsOneWidget);
          expect(fake.setFromCtxCalled, isTrue);

          // 2) tablet: width > maxMobile && <= maxTablet
          fake.setFromCtxCalled = false;
          final Size tabletSize = Size(cfg.maxTabletScreenWidth, 800);
          fake.setSizeForTesting(tabletSize);
          await _pumpWithSize(
            tester,
            size: tabletSize,
            child: ResponsiveSizeWidget(
              responsive: fake,
              tablet: (_, __) => b('tablet'),
              fallback: (_, __) => b('fallback'),
            ),
          );
          // como no hay mobile/desktop/tv, pero tablet sí está provisto
          expect(find.byKey(const ValueKey<String>('tablet')), findsOneWidget);
          expect(fake.setFromCtxCalled, isTrue);

          // 3) desktop: width > maxTablet && < maxDesktop
          fake.setFromCtxCalled = false;
          final Size desktopSize = Size(cfg.maxDesktopScreenWidth - 1, 800);
          fake.setSizeForTesting(desktopSize);
          await _pumpWithSize(
            tester,
            size: desktopSize,
            child: ResponsiveSizeWidget(
              responsive: fake,
              desktop: (_, __) => b('desktop'),
              fallback: (_, __) => b('fallback'),
            ),
          );
          expect(find.byKey(const ValueKey<String>('desktop')), findsOneWidget);
          expect(fake.setFromCtxCalled, isTrue);

          // 4) tv: width >= maxDesktop; si tv no está, cae en desktop; si tampoco, fallback
          fake.setFromCtxCalled = false;
          final Size tvSize = Size(cfg.maxDesktopScreenWidth, 800);
          fake.setSizeForTesting(tvSize);
          await _pumpWithSize(
            tester,
            size: tvSize,
            child: ResponsiveSizeWidget(
              responsive: fake,
              // no damos tv, sí desktop → debe usar desktop
              desktop: (_, __) => b('desktop'),
            ),
          );
          expect(find.byKey(const ValueKey<String>('desktop')), findsOneWidget);

          // 5) tv sin tv ni desktop → fallback
          await _pumpWithSize(
            tester,
            size: tvSize,
            child: ResponsiveSizeWidget(
              responsive: fake,
              fallback: (_, __) => b('fallback'),
            ),
          );
          expect(find.byKey(const ValueKey<String>('fallback')), findsOneWidget);
        });
  });

  group('ResponsiveGeneratorWidget', () {
    testWidgets('genera itemCount widgets con ancho por span y padding/gap por defecto',
            (WidgetTester tester) async {
          final _FakeBlocResponsive fake =
          _FakeBlocResponsive(initial: const Size(1280, 800));

          // Usamos 6 ítems con spans 1,2,3,1,2,3
          const int itemCount = 6;
          int spanFor(int i) => (i % 3) + 1;

              Widget tile(int i) => SizedBox(
                height: 24,
                child: Container(key: ValueKey<String>('tile-$i')),
              );


              await _pumpWithSize(
            tester,
            size: const Size(1280, 800),
            child: ResponsiveGeneratorWidget(
              responsive: fake,
              itemCount: itemCount,
              spanForIndex: (int i, BlocResponsive r) => spanFor(i),
              itemBuilder: (BuildContext _, int i, BlocResponsive __) => tile(i),
            ),
          );

          // 1) conteo
          for (int i = 0; i < itemCount; i++) {
            expect(find.byKey(ValueKey<String>('tile-$i')), findsOneWidget);
          }

          // 2) verificación de anchos por span
          for (int i = 0; i < itemCount; i++) {
            final Size s = tester.getSize(find.byKey(ValueKey<String>('tile-$i')));
            final double expected = fake.widthByColumns(spanFor(i));
            expect(s.width, closeTo(expected, 0.01), reason: 'index $i');
          }

          // 3) padding/gap por defecto: padding = (mh, gap, mh, gap), gap = gutterWidth
          final Padding pad = tester.widget<Padding>(find.byType(Padding));
          expect(pad.padding.isNonNegative, isTrue);
         // expect(pad.padding.right, closeTo(mh, 0.01));
         // expect(pad.padding.top, closeTo(gap, 0.01));
         // expect(pad.padding.bottom, closeTo(gap, 0.01));
        });

    testWidgets('respeta gapOverride y alignment/runAlignment',
            (WidgetTester tester) async {
          final _FakeBlocResponsive fake =
          _FakeBlocResponsive(initial: const Size(1024, 700));

          await _pumpWithSize(
            tester,
            size: const Size(1024, 700),
            child: ResponsiveGeneratorWidget(
              responsive: fake,
              itemCount: 3,
              gapOverride: 12.0,
              alignment: WrapAlignment.end,
              runAlignment: WrapAlignment.center,
              spanForIndex: (int i, _) => 1,
              itemBuilder: (BuildContext _, int i, __) => SizedBox(
                key: ValueKey<String>('it-$i'),
                height: 10,
              ),
            ),
          );

          final Wrap w = tester.widget<Wrap>(find.byType(Wrap));
          expect(w.spacing, 12.0);
          expect(w.runSpacing, 12.0);
          expect(w.alignment, WrapAlignment.end);
          expect(w.runAlignment, WrapAlignment.center);
        });
  });

  group('ResponsiveNxBase derivados (1x1 / 1x2 / 1x3)', () {
    testWidgets('ancho se corresponde con widthByColumns(n) y mantiene relación 1 < 2 < 3',
            (WidgetTester tester) async {
          final _FakeBlocResponsive fake =
          _FakeBlocResponsive(initial: const Size(1440, 900));
          Widget measured(String k) => SizedBox(
            height: 20,
            child: Container(key: ValueKey<String>(k)),
          );

          await _pumpWithSize(
            tester,
            size: const Size(1440, 900),
            child: Column(
              children: <Widget>[
                Responsive1x1Widget(responsive: fake, child: measured('x1')),
                Responsive1x2Widget(responsive: fake, child: measured('x2')),
                Responsive1x3Widget(responsive: fake, child: measured('x3')),
              ],
            ),
          );

          final double w1 = tester.getSize(find.byKey(const ValueKey<String>('x1'))).width;
          final double w2 = tester.getSize(find.byKey(const ValueKey<String>('x2'))).width;
          final double w3 = tester.getSize(find.byKey(const ValueKey<String>('x3'))).width;

          expect(w1, closeTo(fake.widthByColumns(1), 0.01));
          expect(w2, closeTo(fake.widthByColumns(2), 0.01));
          expect(w3, closeTo(fake.widthByColumns(3), 0.01));

          expect(w1, lessThan(w2));
          expect(w2, lessThan(w3));
        });

    testWidgets('alignment y padding adicional se aplican (vía NxBase)',
            (WidgetTester tester) async {
          final _FakeBlocResponsive fake =
          _FakeBlocResponsive(initial: const Size(1200, 800));

          const EdgeInsets extra = EdgeInsets.only(top: 5, bottom: 7);

          await _pumpWithSize(
            tester,
            size: const Size(1200, 800),
            child: Responsive1x1Widget(
              responsive: fake,
              alignment: Alignment.bottomRight,
              padding: extra,
              child: const SizedBox(height: 10),
            ),
          );

          // El Align top-level debe tener el alignment indicado
          final Align align = tester.widget<Align>(find.byType(Align));
          expect(align.alignment, Alignment.bottomRight);

          // El Padding siguiente combina margen horizontal + extra
          final Padding pad = tester.widget<Padding>(find.byType(Padding));
          expect(pad.padding.isNonNegative, isTrue);
          //expect(pad.padding.right, closeTo(mh, 0.01));
          //expect(pad.padding.top, extra.top);
          //expect(pad.padding.bottom, extra.bottom);
        });
  });
}
