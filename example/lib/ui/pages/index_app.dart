import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../../blocs/bloc_counter.dart';
import '../widgets/basic_counter_app.dart';

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
        ],
      ),
    );
  }

  void basicApp(AppManager appManager) {
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
      'Basic app counter 1',
      'BasicAppCounter',
      const BasicCounterApp(),
    );
  }
}
