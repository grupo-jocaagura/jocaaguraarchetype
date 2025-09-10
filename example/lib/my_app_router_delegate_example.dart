import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Demo mínima y autocontenida de navegación con:
///  - PageRegistry (home, test-1, test-2)
///  - PageManager (fuente de verdad)
///  - MyAppRouterDelegate (materializa pages del stack)
///  - MyRouteInformationParser (top-only, URI <-> PageModel)
///
/// Cómo probar:
///  - Desde home, pulsa "Ir a test-1".
///  - En test-1, pulsa "Ir a test-2" o "Volver".
///  - En test-2, prueba "Volver", "Ir a home" o "Ruta inexistente (/no-such)".
///  - También escribe en la barra del navegador: /home, /test-1, /test-2, /no-such
void main() {
  runApp(const NavThreePagesDemo());
}

/// Shell mínimo (sin usar JocaaguraApp) para aislar el router.
/// Aquí montamos nosotros: Provider -> MaterialApp.router
class NavThreePagesDemo extends StatefulWidget {
  const NavThreePagesDemo({super.key});

  @override
  State<NavThreePagesDemo> createState() => _NavThreePagesDemoState();
}

class _NavThreePagesDemoState extends State<NavThreePagesDemo> {
  late final PageRegistry _registry;
  late final AppManager _appManager;
  late final MyAppRouterDelegate _delegate;
  late final MyRouteInformationParser _parser;
  late final PlatformRouteInformationProvider _routeInfoProvider;

  @override
  void initState() {
    super.initState();

    // 1) Registry con 3 páginas y un notFound visual simple (sin redirecciones).
    _registry = PageRegistry.fromDefs(
      <PageDef>[
        PageDef(
          model: const PageModel(name: 'home'),
          builder: (BuildContext ctx, PageModel p) => const _HomePage(),
        ),
        PageDef(
          model: const PageModel(name: 'test-1'),
          builder: (BuildContext ctx, PageModel p) => const _Test1Page(),
        ),
        PageDef(
          model: const PageModel(name: 'test-2'),
          builder: (BuildContext ctx, PageModel p) => const _Test2Page(),
        ),
      ],
      // 404 visual (sin cambiar el stack). Tap en botón => goHome()
      notFoundBuilder: (BuildContext ctx, PageModel req) {
        return Scaffold(
          appBar: AppBar(title: const Text('404')),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Ruta no encontrada: ${req.toUriString()}'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ctx.appManager.pageManager.goHome(),
                  child: const Text('Ir a home'),
                ),
              ],
            ),
          ),
        );
      },
    );

    // 2) AppManager real (usa PageManager interno).
    final AppConfig cfg = AppConfig.dev(registry: _registry);
    _appManager = AppManager(cfg);

    // 3) Delegate y parser (top-only). Desactiva projectorMode para ver el stack completo.
    _delegate = MyAppRouterDelegate(
      registry: _registry,
      pageManager: _appManager.pageManager,
    );
    _parser = const MyRouteInformationParser();

    // 4) Proveedor único para persistir la ubicación (URI) entre hot-reloads.
    _routeInfoProvider = PlatformRouteInformationProvider(
      initialRouteInformation: RouteInformation(uri: Uri(path: '/home')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppManagerProvider(
      appManager: _appManager,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerDelegate: _delegate,
        routeInformationParser: _parser,
        routeInformationProvider: _routeInfoProvider,
        theme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          useMaterial3: true,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          useMaterial3: true,
          brightness: Brightness.dark,
        ),
      ),
    );
  }
}

/// Página: HOME
class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    final PageManager pm = context.appManager.pageManager;
    return Scaffold(
      appBar: AppBar(title: const Text('HOME')),
      body: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            FilledButton(
              onPressed: () => pm.pushNamed('test-1'),
              child: const Text('Ir a test-1 (push)'),
            ),
            OutlinedButton(
              onPressed: () => pm.replaceTopNamed('test-1'),
              child: const Text('Ir a test-1 (replaceTop)'),
            ),
            TextButton(
              onPressed: () => pm.navigateToLocation('/test-1'),
              child: const Text('Ir a /test-1 (URI)'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Página: TEST-1
class _Test1Page extends StatelessWidget {
  const _Test1Page();

  @override
  Widget build(BuildContext context) {
    final PageManager pm = context.appManager.pageManager;
    return Scaffold(
      appBar: AppBar(title: const Text('TEST-1')),
      body: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            FilledButton(
              onPressed: () => pm.pushNamed('test-2'),
              child: const Text('Ir a test-2 (push)'),
            ),
            OutlinedButton(
              onPressed: () => pm.pop(),
              child: const Text('Volver (pop)'),
            ),
            TextButton(
              onPressed: () => pm.navigateToLocation('/test-2'),
              child: const Text('Ir a /test-2 (URI)'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Página: TEST-2
class _Test2Page extends StatelessWidget {
  const _Test2Page();

  @override
  Widget build(BuildContext context) {
    final PageManager pm = context.appManager.pageManager;
    return Scaffold(
      appBar: AppBar(title: const Text('TEST-2')),
      body: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            FilledButton(
              onPressed: () => pm.pop(),
              child: const Text('Volver (pop)'),
            ),
            OutlinedButton(
              onPressed: () => pm.goNamed('home'),
              child: const Text('Ir a home (resetTo)'),
            ),
            TextButton(
              onPressed: () => pm.navigateToLocation('/no-such'),
              child: const Text('Ruta inexistente (/no-such)'),
            ),
          ],
        ),
      ),
    );
  }
}
