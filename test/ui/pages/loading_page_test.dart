import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('LoadingPage', () {
    Future<void> mount(
      WidgetTester tester, {
      required String msg,
      ThemeData? theme,
      ThemeData? darkTheme,
      ThemeMode mode = ThemeMode.light,
      Size? size,
    }) async {
      // Permite testear que el SizedBox toma el tamaño del MediaQuery.

      final Size oldSize = tester.view.physicalSize;
      final double oldDpr = tester.view.devicePixelRatio;

      if (size != null) {
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = size;
        addTearDown(() {
          tester.view.devicePixelRatio = oldDpr;
          tester.view.physicalSize = oldSize;
        });
      }

      await tester.pumpWidget(
        MaterialApp(
          theme: theme ??
              ThemeData.from(
                colorScheme:
                    ColorScheme.fromSeed(seedColor: const Color(0xFF0066CC)),
              ),
          darkTheme: darkTheme,
          themeMode: mode,
          home: LoadingPage(msg: msg),
        ),
      );
      await tester.pump(); // asegura primer frame estabilizado
    }

    testWidgets('smoke: renderiza spinner y el texto del mensaje',
        (WidgetTester tester) async {
      await mount(tester, msg: 'Cargando…');

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Cargando…'), findsOneWidget);
    });

    testWidgets('usa colorScheme.error como background (tema claro)',
        (WidgetTester tester) async {
      final ThemeData t = ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00BCD4),
        ),
      );

      await mount(tester, msg: '...', theme: t);

      final Scaffold sc = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(sc.backgroundColor, t.colorScheme.error);
    });

    testWidgets('usa colorScheme.error del tema oscuro cuando ThemeMode.dark',
        (WidgetTester tester) async {
      final ThemeData dark = ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFAA5500),
          brightness: Brightness.dark,
        ),
      );

      await mount(
        tester,
        msg: '...',
        darkTheme: dark,
        mode: ThemeMode.dark,
      );

      final Scaffold sc = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(sc.backgroundColor, dark.colorScheme.error);
    });

    testWidgets('ocupa el tamaño de MediaQuery (SizedBox ancho/alto)',
        (WidgetTester tester) async {
      const Size sz = Size(800, 600);
      await mount(tester, msg: '...', size: sz);

      // Buscar un SizedBox cuyo width/height coincidan exactamente.
      final Finder sizedFinder = find.byWidgetPredicate(
        (Widget w) =>
            w is SizedBox && w.width == sz.width && w.height == sz.height,
        description: 'SizedBox de pantalla completa',
      );

      expect(sizedFinder, findsOneWidget);
    });

    testWidgets('actualiza el texto al cambiar msg (rebuild)',
        (WidgetTester tester) async {
      final ThemeData base = ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF336699)),
      );

      // Primer render
      await tester.pumpWidget(
        MaterialApp(
          theme: base,
          home: const LoadingPage(msg: 'Preparando…'),
        ),
      );
      await tester.pump();
      expect(find.text('Preparando…'), findsOneWidget);

      // Rebuild con otro mensaje
      await tester.pumpWidget(
        MaterialApp(
          theme: base,
          home: const LoadingPage(msg: 'Cargando datos…'),
        ),
      );
      await tester.pump();
      expect(find.text('Preparando…'), findsNothing);
      expect(find.text('Cargando datos…'), findsOneWidget);
    });
  });
}
