import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Envuelve un [child] en un MaterialApp con ThemeData M3 por defecto.
/// Permite override de tema, locale y textScale.
Future<void> pumpWithApp(
    WidgetTester tester,
    Widget child, {
      ThemeData? theme,
      Locale locale = const Locale('es', 'CO'),
      double textScaleFactor = 1.0,
    }) async {
  final ThemeData effectiveTheme = theme ??
      ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      );

  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      home: MediaQuery(
        data: MediaQuery.of(tester.element(find.byType(MaterialApp)))
            .copyWith(textScaler: TextScaler.linear(textScaleFactor)),
        child: Theme(data: effectiveTheme, child: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

// import 'package:tu_paquete/ui/widgets/responsive_panel.dart';

Widget wrapConstrained(Widget child, {required Size size}) {
  return MediaQuery(
    data: MediaQueryData(size: size),
    child: MaterialApp(home: Scaffold(body: Center(child: child))),
  );
}
class NavProbe extends StatelessWidget {
  const NavProbe({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: <String, WidgetBuilder>{
        '/destino': (_) => const Scaffold(body: Text('Destino')),
      },
      home: Scaffold(body: child),
    );
  }
}
