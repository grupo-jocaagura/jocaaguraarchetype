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
    final AppManager app = context.appManager;

    return Scaffold(
      drawer: StreamBuilder<List<ModelMainMenuModel>>(
        // 🔧 suscríbete al stream para que el drawer reaccione
        stream: app.mainMenu.listMenuOptionsStream,
        initialData: app.mainMenu.listMenuOptions,
        builder: (_, AsyncSnapshot<List<ModelMainMenuModel>> snapshot) {
          final List<ModelMainMenuModel> options =
              snapshot.data ?? const <ModelMainMenuModel>[];
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
                    key: ValueKey<String>('${MyDemoHomePage.maniMenuKey}$i'),
                    onPressed: options[i].onPressed,
                    label: options[i].label,
                    icondata: options[i].iconData,
                  ),
              ],
            ),
          );
        },
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
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
            TextButton(
              onPressed: () {
                app.pushNamed(
                  TestPageBuilderPage.name,
                  title: 'TestPage',
                  // segments/query/kind si los necesitas:
                  // segments: ['test'],
                  // query: {'ref':'home'},
                );
              },
              child: Text('Go to test push page ${app.historyPageNames}'),
            ),
          ],
        ),
      ),
    );
  }
}
