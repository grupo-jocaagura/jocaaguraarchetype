part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Demo home page wired to Jocaagura Archetype navigation & managers.
///
/// This page showcases how to:
/// - Register reactive **main** and **secondary** menu options.
/// - Trigger **loading** (auto and manual clear) and **toasts**.
/// - Randomize **theme**.
/// - Navigate using **PageManager** without pushing raw routes.
///
/// ### Example
/// ```dart
/// // Register the page in your BlocNavigator directory during onboarding:
/// blocNavigator.addPagesForDynamicLinksDirectory({
///   MyDemoHomePage.pageModel.name: const MyDemoHomePage(title: 'Demo'),
/// });
///
/// // Set it as home after onboarding steps:
/// blocNavigator.setHomePageAndUpdate(const MyDemoHomePage(title: 'Demo'));
/// ```
class MyDemoHomePage extends StatefulWidget {
  const MyDemoHomePage({
    required this.title,
    super.key,
  });

  /// Title displayed in the AppBar.
  final String title;

  /// Route name to be used in the dynamic links directory.
  static const String name = 'MyDemoHomePage';

  /// PageModel to keep navigation declarative and UI-domain independent.
  /// Consumers should reference `MyDemoHomePage.page` rather than
  /// constructing `PageModel` manually.
  static const PageModel page = PageModel(
    name: name,
    segments: <String>['home'],
  );

  /// Key prefix used for main menu items rendered by this page.
  static const String mainMenuKey = 'mainMenuKey';

  /// Static PageModel to keep navigation independent from UI.
  static const PageModel pageModel = PageModel(
    name: MyDemoHomePage.name,
    segments: <String>['demo'],
  );

  @override
  State<MyDemoHomePage> createState() => _MyDemoHomePageState();
}

class _MyDemoHomePageState extends State<MyDemoHomePage> {
  int _counter = 0;

  AppManager get app => context.appManager;

  Future<void> _fakeTask() async =>
      Future<void>.delayed(const Duration(seconds: 2));

  /// Adds demo options to main & secondary menus to showcase interactions.
  void _injectDemoMenu() {
    // Add a removable option to main menu
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

    // Loading via built-in future wrapper
    app.mainMenu.addMainMenuOption(
      label: 'Loading (auto)',
      iconData: Icons.hourglass_bottom,
      onPressed: () {
        app.loading.loadingMsgWithFuture('Cargando…', _fakeTask);
      },
    );

    // Loading manual (set + clear)
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

    // Random theme
    app.mainMenu.addMainMenuOption(
      label: 'Cambiar tema',
      iconData: Icons.color_lens,
      onPressed: () {
        app.theme.randomTheme();
        app.mainMenu.removeMainMenuOption('Cambiar tema');
      },
    );

    // Toast toggle
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

  void _incrementCounter() {
    setState(() => _counter++);
    _injectDemoMenu();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const _MainMenuDrawer(prefixKey: MyDemoHomePage.mainMenuKey),
      endDrawer: const _SecondaryMenuDrawer(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: <Widget>[
          StreamBuilder<List<ModelMainMenuModel>>(
            stream: app.secondaryMenu.itemsStream,
            builder: (_, __) {
              return (app.secondaryMenu.items.isNotEmpty)
                  ? IconButton(
                      tooltip: 'Abrir menú secundario',
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                    )
                  : const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: _incrementCounter,
              child: const Text('You have pushed the button this many times:'),
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                app.pageManager.pushOnce(TestPageBuilderPage.pageModel);
              },
              child:
                  Text('Go to test push page ${app.pageManager.historyNames}'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Drawer that listens to **main menu** options reactively.
class _MainMenuDrawer extends StatelessWidget {
  const _MainMenuDrawer({required this.prefixKey});

  /// Prefix to build stable keys for list items.
  final String prefixKey;

  @override
  Widget build(BuildContext context) {
    final AppManager app = context.appManager;
    return StreamBuilder<List<ModelMainMenuModel>>(
      stream: app.mainMenu.listMenuOptionsStream,
      initialData: app.mainMenu.listMenuOptions,
      builder: (_, AsyncSnapshot<List<ModelMainMenuModel>> snapshot) {
        final List<ModelMainMenuModel> options =
            snapshot.data ?? <ModelMainMenuModel>[];
        if (options.isEmpty) {
          return const SizedBox.shrink();
        }

        return Drawer(
          child: ListView(
            children: <Widget>[
              const DrawerHeader(
                child: Center(child: CircularProgressIndicator()),
              ),
              for (int i = 0; i < options.length; i++)
                DrawerOptionWidget(
                  key: ValueKey<String>('${prefixKey}_$i'),
                  label: options[i].label,
                  icon: options[i].iconData,
                  responsive: app.responsive,
                  onTap: options[i].onPressed,
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Drawer that listens to **secondary menu** options reactively.
class _SecondaryMenuDrawer extends StatelessWidget {
  const _SecondaryMenuDrawer();

  @override
  Widget build(BuildContext context) {
    final AppManager app = context.appManager;
    return StreamBuilder<List<ModelMainMenuModel>>(
      stream: app.secondaryMenu.listMenuOptionsStream,
      initialData: app.secondaryMenu.listMenuOptions,
      builder: (_, AsyncSnapshot<List<ModelMainMenuModel>> snapshot) {
        final List<ModelMainMenuModel> options =
            snapshot.data ?? <ModelMainMenuModel>[];
        if (options.isEmpty) {
          return const SizedBox.shrink();
        }

        return Drawer(
          child: ListView(
            children: <Widget>[
              const DrawerHeader(child: Center(child: Icon(Icons.menu_open))),
              for (final ModelMainMenuModel opt in options)
                DrawerOptionWidget(
                  key: ValueKey<String>('secondary_${opt.label}'),
                  label: opt.label,
                  icon: opt.iconData,
                  responsive: app.responsive,
                  onTap: opt.onPressed,
                ),
            ],
          ),
        );
      },
    );
  }
}
