import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import 'blocs/bloc_counter.dart';
import 'ui/pages/index_app.dart';
import 'ui/pages/onboarding_demo_bootstrap.dart';

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
  OnboardingDemoBootstrap(
    blocOnboarding: blocOnboarding,
    child: const IndexApp(),
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
