import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

// revisado 10/03/2024 author: @albertjjimenezp

final AppConfig mockAppConfig = AppConfig(
  blocTheme: MockBlocTheme(
    themeUsecases: ThemeUsecases.fromRepo(
      RepositoryThemeImpl(
        gateway: GatewayThemeImpl(
          themeService: const ServiceJocaaguraArchetypeTheme(),
        ),
      ),
    ),
  ),
  blocUserNotifications: MockBlocUserNotifications(),
  blocLoading: MockBlocLoading(),
  blocMainMenuDrawer: MockBlocMainMenuDrawer(),
  blocSecondaryMenuDrawer: MockBlocSecondaryMenuDrawer(),
  blocResponsive: MockBlocResponsive(),
  blocOnboarding: MockBlocOnboarding(),
  pageManager: MockBlocNavigator(
    initial: NavStackModel(
      const <PageModel>[
        PageModel(name: '/', segments: <String>['home']),
      ],
    ),
  ),
);

class MockAppManager extends AppManager {
  MockAppManager(super.appConfig);

  @override
  BlocResponsive get responsive => MockBlocResponsive();

  @override
  BlocLoading get loading => MockBlocLoading();

  @override
  BlocMainMenuDrawer get mainMenu => MockBlocMainMenuDrawer();

  @override
  BlocSecondaryMenuDrawer get secondaryMenu => MockBlocSecondaryMenuDrawer();

  @override
  BlocTheme get theme => MockBlocTheme(
        themeUsecases: ThemeUsecases.fromRepo(
          RepositoryThemeImpl(
            gateway: GatewayThemeImpl(
              themeService: const ServiceJocaaguraArchetypeTheme(),
            ),
          ),
        ),
      );

  PageManager get navigator => MockBlocNavigator(
        initial: NavStackModel(
          const <PageModel>[
            PageModel(name: '/', segments: <String>['home']),
          ],
        ),
      );

  @override
  BlocOnboarding get onboarding => MockBlocOnboarding();
}

class MockBlocResponsive extends BlocResponsive {
  bool setSizeForTestingCalled = false;
  Size setSizeForTestingSize = Size.zero;

  @override
  void setSizeForTesting(Size size) {
    setSizeForTestingCalled = true;
    setSizeForTestingSize = size;
  }
}

class MockBlocLoading extends BlocLoading {}

class MockBlocMainMenuDrawer extends BlocMainMenuDrawer {
  @override
  List<ModelMainMenuModel> get listMenuOptions => <ModelMainMenuModel>[];
}

class MockBlocSecondaryMenuDrawer extends BlocSecondaryMenuDrawer {}

class MockBlocNavigator extends PageManager {
  MockBlocNavigator({required super.initial});
}

class MockBlocTheme extends BlocTheme {
  MockBlocTheme({required super.themeUsecases});
}

class MockBlocOnboarding extends BlocOnboarding {
  MockBlocOnboarding();

  bool get isOnboardingCompleted => true;

  void setOnboardingCompleted() {}
}

class MockBlocUserNotifications extends BlocUserNotifications {}
