part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

class MyDemoHomePage extends StatefulWidget {
  const MyDemoHomePage({
    required this.title,
    super.key,
  });
  final String title;
  static const String name = 'MyDemoHomePage';
  static const String maniMenuKey = 'mainMenuKey';

  @override
  State<MyDemoHomePage> createState() => _MyDemoHomePageState();
}

class _MyDemoHomePageState extends State<MyDemoHomePage> {
  int _counter = 0;
  Future<void> f() async {
    await Future<void>.delayed(
      const Duration(seconds: 5),
    );
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
      context.appManager.mainMenu.addMainMenuOption(
        onPressed: () {
          context.appManager.secondaryMenu.addSecondaryMenuOption(
            onPressed: () {
              context.appManager.mainMenu.removeMainMenuOption('Eliminame');
              context.appManager.secondaryMenu
                  .removeSecondaryMenuOption('Eliminame');
            },
            label: 'Eliminame',
            iconData: Icons.remove,
          );
        },
        label: 'Eliminame',
        iconData: Icons.remove,
      );

      context.appManager.mainMenu.addMainMenuOption(
        onPressed: () {
          context.appManager.loading.loadingMsgWithFuture('Cargando', f);
        },
        label: 'Loading',
        iconData: Icons.remove,
      );

      context.appManager.secondaryMenu.addSecondaryMenuOption(
        onPressed: () {
          context.appManager.loading.loadingMsg = '';
          context.appManager.mainMenu.removeMainMenuOption('loading');
          context.appManager.mainMenu.removeMainMenuOption('EliminaLoading');
        },
        label: 'EliminaLoading',
        iconData: Icons.remove,
      );

      context.appManager.secondaryMenu.addSecondaryMenuOption(
        onPressed: () async {
          final AppManager appManager = context.appManager;
          appManager.loading.loadingMsg = 'Cargando';
          await f();
          appManager.loading.clearLoading();
          appManager.mainMenu.removeMainMenuOption('EliminaLoadingManual');
        },
        label: 'EliminaLoadingManual',
        iconData: Icons.remove,
      );

      context.appManager.mainMenu.addMainMenuOption(
        onPressed: () {
          context.appManager.theme.randomTheme();
          context.appManager.mainMenu.removeMainMenuOption('Cambia el tema');
        },
        label: 'Cambia el tema',
        iconData: Icons.remove,
      );
      context.appManager.mainMenu.addMainMenuOption(
        onPressed: () {
          final String msg =
              context.appManager.blocUserNotifications.msg.isEmpty
                  ? 'Este es un mensaje de prueba para el toast'
                  : '';
          context.appManager.blocUserNotifications.showToast(msg);
        },
        label: 'toast',
        iconData: Icons.chat_bubble,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO(alberjjimenezp): extraer esto al BlocMainMenu
    final List<Widget> listWidget = <Widget>[];
    int index = 0;
    for (final ModelMainMenuModel element
        in context.appManager.mainMenu.listMenuOptions) {
      listWidget.add(
        DrawerOptionWidget(
          key: ValueKey<String>('${MyDemoHomePage.maniMenuKey}$index'),
          onPressed: element.onPressed,
          label: element.label,
          icondata: element.iconData,
        ),
      );
      index++;
    }
    return Scaffold(
      drawer: listWidget.isNotEmpty
          ? Drawer(
              child: ListView(
                children: <Widget>[
                  const DrawerHeader(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  ...listWidget,
                ],
              ),
            )
          : null,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MaterialButton(
              onPressed: _incrementCounter,
              child: const Text(
                'You have pushed the button this many times:',
              ),
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            MaterialButton(
              onPressed: () {
                context.appManager.navigator.pushPageWidthTitle(
                  'TestPage',
                  TestPageBuilderPage.name,
                  const TestPageBuilderPage(),
                );
              },
              child: Text(
                'Go to test push page ${context.appManager.navigator.historyPageNames}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
