import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import 'blocs/bloc_counter.dart';

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
final BlocOnboarding blocOnboarding = BlocOnboarding();

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
      // todo: add blocConnectivity
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
