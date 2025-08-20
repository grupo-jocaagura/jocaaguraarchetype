import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../../blocs/bloc_counter.dart';
import '../widgets/basic_counter_app.dart';
import '../widgets/second_counter_app.dart';
import 'connectivity_page.dart';
import 'show_toast_page.dart';

class IndexApp extends StatelessWidget {
  const IndexApp({super.key});
  static const PageModel pageModel =
      PageModel(name: 'indexApp', segments: <String>['index-app']);

  static final String name = pageModel.name;
  @override
  Widget build(BuildContext context) {
    final AppManager appManager = context.appManager;

    return Scaffold(
      appBar: AppBar(
        title: Text(appManager.page.currentTitle),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('Go to basic counter'),
            subtitle: const Text('Here we go!! To basic app demo'),
            onTap: () => basicApp(appManager),
          ),
          ListTile(
            title: const Text('Go to Second counter'),
            subtitle: const Text('Here we go!! To second app demo'),
            onTap: () => basicApp(
              appManager,
              PageWidget(
                routeName: SecondCounterApp.pageModel.name,
                title: 'Secondary app',
                widget: const SecondCounterApp(),
              ),
            ),
          ),
          ListTile(
            title: const Text('Go to fake connectivity'),
            subtitle: const Text('Here we go!! To see connectivity'),
            onTap: () => basicApp(
              appManager,
              const PageWidget(
                routeName: 'ConnectivityPage',
                title: 'Connectivity test',
                widget: ConnectivityPage(),
              ),
            ),
          ),
          ListTile(
            title: const Text('Go to snackbar test'),
            subtitle: const Text('Here we go!! To see snackbar'),
            onTap: () => basicApp(
              appManager,
              PageWidget(
                routeName: ShowToastPage.pageModel.name,
                title: 'Show toast test',
                widget: const ShowToastPage(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void basicApp(
    AppManager appManager, [
    PageWidget app = const PageWidget(
      title: 'BasicCounterApp',
      routeName: 'BasicCounterApp',
      widget: BasicCounterApp(),
    ),
  ]) {
    final BlocCounter blocCounter =
        appManager.blocCore.getBlocModule<BlocCounter>(BlocCounter.name);
    appManager.secondaryMenu.clearSecondaryDrawer();
    appManager.secondaryMenu.addSecondaryMenuOption(
      onPressed: () {
        blocCounter.add();
      },
      label: 'Add 1',
      iconData: Icons.add,
    );
    appManager.secondaryMenu.addSecondaryMenuOption(
      onPressed: () {
        blocCounter.decrement();
      },
      label: 'Quita 1',
      iconData: Icons.remove,
    );
    appManager.mainMenu.addMainMenuOption(
      onPressed: () {
        blocCounter.reset();
        appManager.secondaryMenu.clearSecondaryDrawer();
        appManager.page.pop();
      },
      label: 'Reset and back',
      iconData: Icons.reset_tv,
    );

    appManager.page.pushNamed(
      app.routeName,
      title: app.title,
    );
  }
}

class PageWidget {
  const PageWidget({
    required this.routeName,
    required this.title,
    required this.widget,
    this.arguments,
  });

  final String routeName;
  final String title;
  final Widget widget;
  final Object? arguments;
}
