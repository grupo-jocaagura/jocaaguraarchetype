part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// BLoC minimalista para la demo (contador + stream).
class _BlocCounter extends BlocModule {
  _BlocCounter() : _count = BlocGeneral<int>(0);

  final BlocGeneral<int> _count;

  Stream<int> get stream => _count.stream;
  int get value => _count.value;

  void inc() => _count.value = _count.value + 1;

  @override
  void dispose() => _count.dispose();
}

/// Página de demo que **no crea Scaffold** propio.
/// En su lugar usa `PageBuilder` para integrarse al shell del arquetipo
/// (AppBar, Drawer, overlay de loading y toasts).
class MyDemoHomePage extends StatefulWidget {
  const MyDemoHomePage({required this.title, super.key});

  final String title;

  static const String name = 'MyDemoHomePage';

  static const PageModel pageModel = PageModel(
    name: name,
    segments: <String>['demo'],
    state: <String, dynamic>{'title': 'Demo'},
  );

  @override
  State<MyDemoHomePage> createState() => _MyDemoHomePageState();
}

class _MyDemoHomePageState extends State<MyDemoHomePage> {
  late final _BlocCounter _counter;

  AbstractAppManager get app => context.appManager;

  @override
  void initState() {
    super.initState();
    _counter = _BlocCounter();
  }

  @override
  void dispose() {
    _counter.dispose();
    super.dispose();
  }

  Future<void> _fakeTask() async =>
      Future<void>.delayed(const Duration(seconds: 2));

  void _injectDemoMenu() {
    // Opción que prepara eliminación a través del menú secundario
    app.mainMenu.addMainMenuOption(
      label: 'Eliminame',
      iconData: Icons.remove,
      onPressed: () {
        app.secondaryMenu.addSecondaryMenuOption(
          label: 'Eliminame',
          iconData: Icons.remove,
          onPressed: () {
            app.mainMenu.removeMainMenuOption('Eliminame');
            app.secondaryMenu.removeSecondaryMenuOption('Eliminame');
          },
        );
      },
    );

    // Loading (auto) usando helper
    app.mainMenu.addMainMenuOption(
      label: 'Loading (auto)',
      iconData: Icons.hourglass_bottom,
      onPressed: () {
        app.loading.loadingMsgWithFuture('Cargando…', _fakeTask);
      },
    );

    // Loading (manual) → secundario (no visible por PageBuilder, pero útil en flows)
    app.secondaryMenu.addSecondaryMenuOption(
      label: 'Loading (manual)',
      iconData: Icons.hourglass_top,
      onPressed: () async {
        app.loading.loadingMsg = 'Cargando…';
        await _fakeTask();
        app.loading.clearLoading();
        app.secondaryMenu.removeSecondaryMenuOption('Loading (manual)');
      },
    );

    // Random theme (y se auto-quita del menú principal)
    app.mainMenu.addMainMenuOption(
      label: 'Cambiar tema',
      iconData: Icons.color_lens,
      onPressed: () {
        app.theme.randomTheme();
        app.mainMenu.removeMainMenuOption('Cambiar tema');
      },
    );

    // Toast con toggle vacío/visible (overlay lo maneja PageBuilder)
    app.mainMenu.addMainMenuOption(
      label: 'Toast demo',
      iconData: Icons.chat_bubble,
      onPressed: () {
        final String msg = app.notifications.msg.isEmpty
            ? 'Este es un mensaje de prueba para el toast'
            : '';
        app.notifications.showToast(msg);
      },
    );
  }

  void _onIncrement() {
    _counter.inc();
    _injectDemoMenu();
  }

  @override
  Widget build(BuildContext context) {
    // El contenido **puro**: PageBuilder envuelve y aporta AppBar/Drawer/overlays
    final Widget content = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextButton(
            onPressed: _onIncrement,
            child: const Text('You have pushed the button this many times:'),
          ),
          StreamBuilder<int>(
            stream: _counter.stream,
            initialData: _counter.value,
            builder: (_, AsyncSnapshot<int> snap) {
              return Text(
                '${snap.data ?? 0}',
                style: Theme.of(context).textTheme.headlineMedium,
              );
            },
          ),
          const SizedBox(height: 12),
          // Ejemplo de navegación (no lo usamos en los tests de esta demo)
          TextButton(
            onPressed: () {
              app.pageManager.pushOnce(
                const PageModel(
                  name: 'testPush',
                  segments: <String>['test-push'],
                  state: <String, dynamic>{'title': 'Test push'},
                ),
              );
            },
            child: Text('Go to test push page ${app.pageManager.historyNames}'),
          ),
        ],
      ),
    );

    // ✅ Aquí integramos el contenido con el shell del arquetipo
    return PageBuilder(page: content);
  }
}
