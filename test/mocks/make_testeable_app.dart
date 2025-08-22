import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

late AppManager jAppManager;

Widget makeTesteablePage({
  required Widget child,
}) {
  final ThemeUsecases themeUsecases = ThemeUsecases.fromRepo(
    RepositoryThemeImpl(
      gateway: GatewayThemeImpl(
        themeService: const ServiceJocaaguraArchetypeTheme(),
      ),
    ),
  );

  /// Zona de configuración inicial
  final BlocTheme blocTheme = BlocTheme(themeUsecases: themeUsecases);
  final BlocUserNotifications blocUserNotifications = BlocUserNotifications();
  final BlocLoading blocLoading = BlocLoading();
  final BlocMainMenuDrawer blocMainMenuDrawer = BlocMainMenuDrawer();
  final BlocSecondaryMenuDrawer blocSecondaryMenuDrawer =
      BlocSecondaryMenuDrawer();
  final BlocResponsive blocResponsive = BlocResponsive();
  final BlocOnboarding blocOnboarding = BlocOnboarding();
  final PageRegistry registry = PageRegistry(<String, PageWidgetBuilder>{
    // Ruta inicial "home"
    '/': (BuildContext context, PageModel page) => const Scaffold(),
  });

  jAppManager = AppManager(
    AppConfig(
      blocTheme: blocTheme,
      blocUserNotifications: blocUserNotifications,
      blocLoading: blocLoading,
      blocMainMenuDrawer: blocMainMenuDrawer,
      blocSecondaryMenuDrawer: blocSecondaryMenuDrawer,
      blocResponsive: blocResponsive,
      blocOnboarding: blocOnboarding,
      pageManager: PageManager(
        initial: NavStackModel(
          const <PageModel>[
            PageModel(name: '/', segments: <String>['home']),
          ],
        ),
      ),
    ),
  );

  return JocaaguraApp(
    appManager: jAppManager,
    registry: registry,
  );
}
