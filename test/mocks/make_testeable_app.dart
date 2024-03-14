import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

late AppManager jAppManager;

Widget makeTesteablePage({
  required Widget child,
}) {
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
    <Future<void> Function()>[],
  );

  final BlocNavigator blocNavigator = BlocNavigator(
    PageManager(),
    child,
  );
  jAppManager = AppManager(
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
  );

  return JocaaguraApp(
    appManager: jAppManager,
  );
}
