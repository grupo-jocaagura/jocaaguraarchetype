import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/app_config.dart';
import 'package:jocaaguraarchetype/blocs/app_manager.dart';
import 'package:jocaaguraarchetype/blocs/bloc_loading.dart';
import 'package:jocaaguraarchetype/blocs/bloc_main_menu.dart';
import 'package:jocaaguraarchetype/blocs/bloc_navigator.dart';
import 'package:jocaaguraarchetype/blocs/bloc_onboarding.dart';
import 'package:jocaaguraarchetype/blocs/bloc_responsive.dart';
import 'package:jocaaguraarchetype/blocs/bloc_secondary_menu.dart';
import 'package:jocaaguraarchetype/blocs/bloc_theme.dart';
import 'package:jocaaguraarchetype/blocs/bloc_user_notifications.dart';
import 'package:jocaaguraarchetype/models/model_main_menu.dart';

import 'pagemanager_mock.dart';
import 'provider_theme_mock.dart';

// revisado 10/03/2024 author: @albertjjimenezp

final AppConfig mockAppConfig = AppConfig(
  blocTheme: MockBlocTheme(ProviderThemeMock()),
  blocUserNotifications: MockBlocUserNotifications(),
  blocLoading: MockBlocLoading(),
  blocMainMenuDrawer: MockBlocMainMenuDrawer(),
  blocSecondaryMenuDrawer: MockBlocSecondaryMenuDrawer(),
  blocResponsive: MockBlocResponsive(),
  blocOnboarding: MockBlocOnboarding(<FutureOr<void> Function()>[]),
  blocNavigator: MockBlocNavigator(MockPageManager()),
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
  BlocTheme get theme => MockBlocTheme(ProviderThemeMock());

  @override
  BlocNavigator get navigator => MockBlocNavigator(MockPageManager());

  @override
  BlocOnboarding get onboarding =>
      MockBlocOnboarding(<FutureOr<void> Function()>[]);
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
  List<ModelMainMenu> get listMenuOptions => <ModelMainMenu>[];
}

class MockBlocSecondaryMenuDrawer extends BlocSecondaryMenuDrawer {}

class MockBlocTheme extends BlocTheme {
  MockBlocTheme(super.providerTheme);

  @override
  ThemeData get themeData => ThemeData();
}

class MockBlocNavigator extends BlocNavigator {
  MockBlocNavigator(super.pageManager);
}

class MockBlocOnboarding extends BlocOnboarding {
  MockBlocOnboarding(super.blocOnboardingList);

  bool get isOnboardingCompleted => true;

  void setOnboardingCompleted() {}
}

class MockBlocUserNotifications extends BlocUserNotifications {}
