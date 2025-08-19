import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import 'blocs/bloc_counter.dart';
import 'ui/pages/index_app.dart';
import 'ui/pages/onboarding_demo_bootstrap.dart';

/// ```md
///
/// ## Wiring mínimo (recordatorio)
///
/// * Construyes **GatewayThemeImpl** (con `ServiceTheme` y opcional `DefaultErrorMapper`).
/// * Construyes **RepositoryThemeImpl** con el gateway.
/// * Construyes **ThemeUseCases** con el repo.
/// * Construyes **BlocTheme** con los **use cases**.
///
/// ```dart
/// final ServiceTheme themeService = const ServiceJocaaguraArchetypeTheme();
/// final GatewayTheme gateway      = GatewayThemeImpl(themeService: themeService);
/// final RepositoryTheme repo      = RepositoryThemeImpl(gateway: gateway);
/// final ThemeUseCases usecases    = ThemeUseCases(repo);
/// final BlocTheme blocTheme       = BlocTheme(usecases);
/// ```
///
/// Con esto, el BLoC queda perfectamente alineado al flujo “Domain-First”:
/// **UI → Bloc (acciones) → UseCases → Repository → Gateway → (Service para validar/smoke-test)**.
/// ```
///
///
///
final GatewayTheme gatewayTheme = GatewayThemeImpl();
final RepositoryTheme repositoryTheme = RepositoryThemeImpl(
  gateway: gatewayTheme,
);
ThemeUsecases themeUseCases = ThemeUsecases.fromRepo(repositoryTheme);

/// Zona de configuración inicial
final BlocTheme blocTheme = BlocTheme(
  themeUsecases: themeUseCases,
);

final BlocUserNotifications blocUserNotifications = BlocUserNotifications();
final BlocLoading blocLoading = BlocLoading();
final BlocMainMenuDrawer blocMainMenuDrawer = BlocMainMenuDrawer();
final BlocSecondaryMenuDrawer blocSecondaryMenuDrawer =
    BlocSecondaryMenuDrawer();
final BlocResponsive blocResponsive = BlocResponsive();
final BlocOnboarding blocOnboarding = BlocOnboarding();

final RepositoryConnectivityImpl repo = RepositoryConnectivityImpl(
  GatewayConnectivityImpl(FakeServiceConnectivity(), DefaultErrorMapper()),
);

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
    ),
  );
}
