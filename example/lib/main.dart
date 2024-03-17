import 'package:example/blocs/bloc_counter.dart';
import 'package:example/ui/pages/my_home_page.dart';
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
    blocModuleList: {BlocCounter.name: BlocCounter()},
  ),
);

void main() {
  runApp(JocaaguraApp(
    appManager: appManager,
  ));
}
