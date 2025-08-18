import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../../blocs/bloc_counter.dart';
import 'basic_app_counter_widget.dart';
import 'one_x_one_widget.dart';

class SecondCounterApp extends StatelessWidget {
  const SecondCounterApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    /// representaremos 4 Scaffolds de acuerdo a cada pantalla
    final AppManager appManager = context.appManager;
    final BlocCounter blocCounter =
        appManager.blocCore.getBlocModule<BlocCounter>(BlocCounter.name);

    final Size size = MediaQuery.of(context).size;
    final AppBar appBar = AppBar(
      title: Text('II ${appManager.responsive.deviceType} - $size'),
      leading: appManager.navigator.showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => appManager.navigator.back(),
            )
          : null,
      actions: <Widget>[
        if (appManager.mainMenu.listMenuOptions.isNotEmpty)
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              );
            },
          ),
      ],
    );

    if (appManager.responsive.isTv) {
      final List<ListTile> mainMenuTile = <ListTile>[];

      for (final ModelMainMenuModel element
          in appManager.mainMenu.listMenuOptions) {
        mainMenuTile.add(
          ListTile(
            title: Text(element.label),
            onTap: element.onPressed,
            subtitle: Text(element.description),
          ),
        );
      }

      return Scaffold(
        drawer: appManager.mainMenu.listMenuOptions.isNotEmpty
            ? Drawer(
                child: MainMenuWidget(
                  drawerWidth: appManager.responsive.drawerWidth,
                  listMenuOptions: appManager.mainMenu.listMenuOptions,
                ),
              )
            : null,
        body: Row(
          children: <Widget>[
            Container(
              width: appManager.responsive.columnWidth,
              color: Theme.of(context).splashColor,
              child: ListView(
                children: mainMenuTile,
              ),
            ),
            PageWidthSecondaryMenuWidget(
              screenSizeEnum: ScreenSizeEnum.desktop,
              secondaryMenuWidth: appManager.responsive.drawerWidth,
              page: Center(
                child: SizedBox(
                  width: appManager.responsive.workAreaSize.width -
                      appManager.responsive.columnWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          OneXOneWidget(
                            child: BasicAppCounterWidget(
                              blocCounter: blocCounter,
                            ),
                          ),
                          SizedBox(
                            width: 200,
                            height: 100,
                            child: BasicAppCounterWidget(
                              blocCounter: blocCounter,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 300,
                        height: 100,
                        child: BasicAppCounterWidget(
                          blocCounter: blocCounter,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          SizedBox(
                            width: 288,
                            height: 162,
                            child: BasicAppCounterWidget(
                              blocCounter: blocCounter,
                            ),
                          ),
                          SizedBox(
                            width: 162,
                            height: 288,
                            child: BasicAppCounterWidget(
                              blocCounter: blocCounter,
                            ),
                          ),
                        ],
                      ),
                      MyAppButtonWidget(
                        iconData: Icons.sports_football,
                        label: 'Paso',
                        onPressed: blocCounter.add,
                      ),
                    ],
                  ),
                ),
              ),
              listOfModelMainMenu: appManager.secondaryMenu.listMenuOptions,
            ),
          ],
        ),
      );
    }
    if (appManager.responsive.isDesktop) {
      return Scaffold(
        drawer: appManager.mainMenu.listMenuOptions.isNotEmpty
            ? Drawer(
                child: MainMenuWidget(
                  drawerWidth: appManager.responsive.drawerWidth,
                  listMenuOptions: appManager.mainMenu.listMenuOptions,
                ),
              )
            : null,
        appBar: AppBar(
          title: Text('${appManager.responsive.deviceType} - $size'),
          leading: appManager.navigator.showBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () => appManager.navigator.back(),
                )
              : null,
          actions: <Widget>[
            if (appManager.mainMenu.listMenuOptions.isNotEmpty)
              Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  );
                },
              ),
          ],
        ),
        body: PageWidthSecondaryMenuWidget(
          screenSizeEnum: ScreenSizeEnum.desktop,
          secondaryMenuWidth: appManager.responsive.drawerWidth,
          page: Center(
            child: SizedBox(
              width: appManager.responsive.workAreaSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      OneXOneWidget(
                        child: BasicAppCounterWidget(
                          blocCounter: blocCounter,
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        height: 100,
                        child: BasicAppCounterWidget(
                          blocCounter: blocCounter,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 300,
                    height: 100,
                    child: BasicAppCounterWidget(
                      blocCounter: blocCounter,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      SizedBox(
                        width: 288,
                        height: 162,
                        child: BasicAppCounterWidget(
                          blocCounter: blocCounter,
                        ),
                      ),
                      SizedBox(
                        width: 162,
                        height: 288,
                        child: BasicAppCounterWidget(
                          blocCounter: blocCounter,
                        ),
                      ),
                    ],
                  ),
                  MyAppButtonWidget(
                    iconData: Icons.sports_football,
                    label: 'Paso',
                    onPressed: blocCounter.add,
                  ),
                ],
              ),
            ),
          ),
          listOfModelMainMenu: appManager.secondaryMenu.listMenuOptions,
        ),
      );
    }

    if (appManager.responsive.isTablet) {
      return Scaffold(
        drawer: appManager.mainMenu.listMenuOptions.isNotEmpty
            ? Drawer(
                child: MainMenuWidget(
                  drawerWidth: appManager.responsive.drawerWidth,
                  listMenuOptions: appManager.mainMenu.listMenuOptions,
                ),
              )
            : null,
        appBar: AppBar(
          title: Text('${appManager.responsive.deviceType} - $size'),
          leading: appManager.navigator.showBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () => appManager.navigator.back(),
                )
              : null,
          actions: <Widget>[
            if (appManager.mainMenu.listMenuOptions.isNotEmpty)
              Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  );
                },
              ),
          ],
        ),
        body: PageWidthSecondaryMenuWidget(
          screenSizeEnum: ScreenSizeEnum.tablet,
          secondaryMenuWidth: appManager.responsive.secondaryDrawerWidth,
          page: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      OneXOneWidget(
                        child: BasicAppCounterWidget(
                          blocCounter: blocCounter,
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        height: 100,
                        child: BasicAppCounterWidget(
                          blocCounter: blocCounter,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 300,
                    height: 100,
                    child: BasicAppCounterWidget(
                      blocCounter: blocCounter,
                    ),
                  ),
                  SizedBox(
                    width: 288,
                    height: 162,
                    child: BasicAppCounterWidget(
                      blocCounter: blocCounter,
                    ),
                  ),
                  SizedBox(
                    width: 162,
                    height: 288,
                    child: BasicAppCounterWidget(
                      blocCounter: blocCounter,
                    ),
                  ),
                  MyAppButtonWidget(
                    iconData: Icons.sports_football,
                    label: 'Paso',
                    onPressed: blocCounter.add,
                  ),
                ],
              ),
            ),
          ),
          listOfModelMainMenu: appManager.secondaryMenu.listMenuOptions,
        ),
      );
    }

    // movil es el default
    return Scaffold(
      drawer: appManager.mainMenu.listMenuOptions.isNotEmpty
          ? Drawer(
              child: MainMenuWidget(
                drawerWidth: appManager.responsive.drawerWidth,
                listMenuOptions: appManager.mainMenu.listMenuOptions,
              ),
            )
          : null,
      appBar: appBar,
      body: PageWidthSecondaryMenuWidget(
        page: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                OneXOneWidget(
                  child: BasicAppCounterWidget(
                    blocCounter: blocCounter,
                  ),
                ),
                SizedBox(
                  width: 200,
                  height: 100,
                  child: BasicAppCounterWidget(
                    blocCounter: blocCounter,
                  ),
                ),
                SizedBox(
                  width: 300,
                  height: 100,
                  child: BasicAppCounterWidget(
                    blocCounter: blocCounter,
                  ),
                ),
                SizedBox(
                  width: 288,
                  height: 162,
                  child: BasicAppCounterWidget(
                    blocCounter: blocCounter,
                  ),
                ),
                SizedBox(
                  width: 162,
                  height: 288,
                  child: BasicAppCounterWidget(
                    blocCounter: blocCounter,
                  ),
                ),
                MyAppButtonWidget(
                  iconData: Icons.sports_football,
                  label: 'Paso',
                  onPressed: blocCounter.add,
                ),
              ],
            ),
          ),
        ),
        screenSizeEnum: appManager.responsive.deviceType,
        listOfModelMainMenu: appManager.secondaryMenu.listMenuOptions,
        secondaryMenuWidth: 80.0,
      ),
    );
  }
}
