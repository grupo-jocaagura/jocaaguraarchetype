import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/blocs/bloc_connectivity.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
import 'package:jocaaguraarchetype/services/service_connectivity.dart';

import 'blocs/bloc_counter.dart';
import 'ui/pages/my_home_page.dart';

final JocaaguraArchetype jocaaguraArchetype = JocaaguraArchetype();

/// Zona de configuración inicial
final BlocTheme blocTheme = BlocTheme(
  const ProviderTheme(
    ServiceTheme(),
  ),
);
final BlocConnectivity blocConnectivity = BlocConnectivity(
  ServiceConnectivity(
    const FakeConnectivityProvider(),
    const FakeInternetProvider(),
    debouncer: Debouncer(milliseconds: 1000),
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

final AppManager appManager = AppManager(
  AppConfig(
    blocTheme: blocTheme,
    blocUserNotifications: blocUserNotifications,
    blocLoading: blocLoading,
    blocMainMenuDrawer: blocMainMenuDrawer,
    blocSecondaryMenuDrawer: blocSecondaryMenuDrawer,
    blocResponsive: blocResponsive,
    blocOnboarding: blocOnboarding,
    blocNavigator: blocNavigator,
    blocModuleList: <String, BlocModule>{
      BlocCounter.name: BlocCounter(),
      BlocConnectivity.name: blocConnectivity,
    },
  ),
);

void main() {
  runApp(
    JocaaguraApp(
      appManager: appManager,
    ),
  );
}
