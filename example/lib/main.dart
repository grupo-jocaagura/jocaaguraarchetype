import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

final JocaaguraArchetype jocaaguraArchetype = JocaaguraArchetype();

/// Zona de configuración inicial
final BlocTheme blocTheme = BlocTheme(
  const ProviderTheme(
    ServiceTheme(),
  ),
);
final BlocUserNotifications blocUserNotifications = BlocUserNotifications();
final BlocLoading blocLoading = BlocLoading();
final BlocMainMenuDrawer blocMainMenuDrawer = BlocMainMenuDrawer();
final BlocSecondaryMenuDrawer blocSecondaryMenuDrawer =
    BlocSecondaryMenuDrawer();
final BlocResponsive blocResponsive = BlocResponsive();
final BlocOnboarding blocOnboarding = BlocOnboarding(
  <Future<void> Function()>[
    // reemplazar por las funciones iniciales de configuración
    () async {
      blocNavigator.addPagesForDynamicLinksDirectory(<String, Widget>{
        MyDemoHomePage.name: const MyDemoHomePage(title: 'Prueba'),
      });
    },
    jocaaguraArchetype.testMe,
    jocaaguraArchetype.testMe,
    jocaaguraArchetype.testMe,
    jocaaguraArchetype.testMe,
    () async {
      blocNavigator.setHomePageAndUpdate(
        const MyHomePage(),
      );
    },
  ],
);
final BlocNavigator blocNavigator = BlocNavigator(
  PageManager(),
  OnBoardingPage(
    blocOnboarding: blocOnboarding,
  ),
);

void main() {
  runApp(JocaaguraApp(
    appManager: AppManager(
      AppConfig(
        blocTheme: blocTheme,
        blocUserNotifications: blocUserNotifications,
        blocLoading: blocLoading,
        blocMainMenuDrawer: blocMainMenuDrawer,
        blocSecondaryMenuDrawer: blocSecondaryMenuDrawer,
        blocResponsive: blocResponsive,
        blocOnboarding: blocOnboarding,
        blocNavigator: blocNavigator,
      ),
    ),
  ));
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter = jocaaguraArchetype.addOne(_counter);
    });
  }

  void changeTheme() {
    context.appManager.theme.randomTheme();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Flutter Demo Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            InkWell(
              onTap: () {
                final navigator = context.appManager.navigator;
                navigator.setTitle('my demo page');
                navigator.pushNamed('MyDemoHomePage');
              },
              child: const Text(
                'You have pushed the button this many times:',
              ),
            ),
            InkWell(
              onTap: changeTheme,
              child: Text(
                '$_counter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
