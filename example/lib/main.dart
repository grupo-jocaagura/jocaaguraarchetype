// example/main.dart
import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import 'blocs/bloc_counter.dart';
import 'ui/pages/connectivity_page.dart';
import 'ui/pages/index_app.dart';
import 'ui/pages/my_home_page.dart';
import 'ui/pages/show_toast_page.dart';
import 'ui/widgets/basic_counter_app.dart';
import 'ui/widgets/second_counter_app.dart';

/// --- 1) Theme wiring (Domain-first) ---
final GatewayTheme gatewayTheme = GatewayThemeImpl();
final RepositoryTheme repositoryTheme =
    RepositoryThemeImpl(gateway: gatewayTheme);
final ThemeUsecases themeUseCases = ThemeUsecases.fromRepo(repositoryTheme);
final BlocTheme blocTheme = BlocTheme(themeUsecases: themeUseCases);

/// --- 2) Otros blocs base ---
final BlocUserNotifications blocUserNotifications = BlocUserNotifications();
final BlocLoading blocLoading = BlocLoading();
final BlocMainMenuDrawer blocMainMenuDrawer = BlocMainMenuDrawer();
final BlocSecondaryMenuDrawer blocSecondaryMenuDrawer =
    BlocSecondaryMenuDrawer();
final BlocResponsive blocResponsive = BlocResponsive();
final BlocOnboarding blocOnboarding = BlocOnboarding();

/// --- 3) (Ejemplo) Conectividad opcional ---
final RepositoryConnectivityImpl repo = RepositoryConnectivityImpl(
  GatewayConnectivityImpl(FakeServiceConnectivity(), DefaultErrorMapper()),
);

/// --- 4) PageRegistry: mapea 'name' → (ctx, page) => widget ---
final PageRegistry registry = PageRegistry(<String, PageWidgetBuilder>{
  // Ruta inicial "home"
  IndexApp.pageModel.name: (BuildContext context, PageModel page) =>
      const IndexApp(),
  '/': (BuildContext context, PageModel page) => const IndexApp(),
  MyHomePage.pageModel.name: (BuildContext context, PageModel page) =>
      const MyHomePage(),
  ConnectivityPage.pageModel.name: (BuildContext context, PageModel page) =>
      const ConnectivityPage(),
  ShowToastPage.pageModel.name: (BuildContext context, PageModel page) =>
      const ShowToastPage(),
  BasicCounterApp.pageModel.name: (BuildContext context, PageModel page) =>
      const BasicCounterApp(),
  SecondCounterApp.pageModel.name: (BuildContext context, PageModel page) =>
      const SecondCounterApp(),
});

/// --- 5) PageManager: fuente de verdad de navegación ---
final PageManager pageManager = PageManager(
  initial: NavStackModel.single(
    IndexApp.pageModel,
  ),
);

/// --- 6) AppManager + AppConfig (registra TODOS los blocs + PageManager) ---
final AppManager appManager = AppManager(
  AppConfig(
    blocTheme: blocTheme,
    blocUserNotifications: blocUserNotifications,
    blocLoading: blocLoading,
    blocMainMenuDrawer: blocMainMenuDrawer,
    blocSecondaryMenuDrawer: blocSecondaryMenuDrawer,
    blocResponsive: blocResponsive,
    blocOnboarding: blocOnboarding,
    pageManager: pageManager, // << importante: registrar el PageManager
    blocModuleList: <String, BlocModule>{
      BlocCounter.name: BlocCounter(),
      'BlocConnectivity': BlocConnectivity(
        watch: WatchConnectivityUseCase(repo),
        snapshot: GetConnectivitySnapshotUseCase(repo),
        checkType: CheckConnectivityTypeUseCase(repo),
        checkSpeed: CheckInternetSpeedUseCase(repo),
      ),
    },
  ),
);

void main() {
  runApp(
    JocaaguraApp(
      appManager: appManager,
      registry: registry,
      routeInformationParser: MyRouteInformationParser(
        defaultRouteName: MyHomePage.pageModel.name,
      ),
    ),
  );
}
