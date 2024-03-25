import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../../blocs/bloc_counter.dart';
import '../widgets/basic_counter_app.dart';
import '../widgets/second_counter_app.dart';

class IndexApp extends StatelessWidget {
  const IndexApp({super.key});
  static const String name = 'indexApp';
  @override
  Widget build(BuildContext context) {
    final AppManager appManager = context.appManager;

    return Scaffold(
      appBar: AppBar(
        title: Text(appManager.navigator.title),
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
              const PageWidget(
                routeName: 'SecondCounterApp',
                title: 'Secondary app',
                widget: SecondCounterApp(),
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
      title: 'Basic app counter 1',
      routeName: 'BasicAppCounter',
      widget: BasicCounterApp(),
    ),
  ]) {
    final BlocCounter blocCounter =
        appManager.blocCore.getBlocModule<BlocCounter>(BlocCounter.name);
    appManager.secondaryMenu.clearMainDrawer();
    appManager.secondaryMenu.addMainMenuOption(
      onPressed: () {
        blocCounter.add();
      },
      label: 'Add 1',
      iconData: Icons.add,
    );
    appManager.secondaryMenu.addMainMenuOption(
      onPressed: () {
        blocCounter.decrement();
      },
      label: 'Quita 1',
      iconData: Icons.remove,
    );
    appManager.mainMenu.addMainMenuOption(
      onPressed: () {
        blocCounter.reset();
        appManager.secondaryMenu.clearMainDrawer();
        appManager.navigator.back();
      },
      label: 'Reset and back',
      iconData: Icons.reset_tv,
    );

    appManager.navigator.pushPageWidthTitle(
      app.title,
      app.routeName,
      app.widget,
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
