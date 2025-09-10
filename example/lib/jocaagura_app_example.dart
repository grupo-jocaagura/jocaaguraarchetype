import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Minimal demo that wires a custom AppManager into JocaaguraApp.
///
/// - Builds a PageRegistry with three pages and a custom 404.
/// - Creates an AppConfig.dev (keeps archetype defaults) and an AppManager.
/// - Passes both to JocaaguraApp (which owns nothing in this variant).
///
/// How to try:
/// - From home → "Ir a test-1".
/// - From test-1 → "Ir a test-2" / "Volver".
/// - From test-2 → "Volver" / "Ir a home" / "Ruta inexistente (/no-such)".
/// - Type /home, /test-1, /test-2, /no-such in the browser bar.
void main() {
  // 1) Registry with pages + a simple visual 404 (no redirects).
  final PageRegistry registry = PageRegistry.fromDefs(
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

  // 2) AppManager real a partir de AppConfig.dev (usa PageManager interno).
  final AppConfig cfg = AppConfig.dev(registry: registry);
  final AppManager manager = AppManager(cfg);

  // 3) JocaaguraApp con manager propio (ownsManager=false: lo dispones tú si hiciera falta).
  runApp(
    JocaaguraApp(
      appManager: manager,
      registry: registry,
      projectorMode:
          true, // top-only rendering; pon false para ver stack completo
      initialLocation: '/home', // semilla de localización
      ownsManager: false, // en esta variante NO cede el dispose al widget
    ),
  );
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
