import 'dart:async';

import '../app_config.dart';
import '../entities/entity_bloc.dart';
import 'bloc_loading.dart';
import 'bloc_main_menu.dart';
import 'bloc_navigator.dart';
import 'bloc_onboarding.dart';
import 'bloc_responsive.dart';
import 'bloc_secondary_menu.dart';
import 'bloc_theme.dart';
import 'bloc_user_notifications.dart';

class AppManager {
  const AppManager(this.appConfig);

  final AppConfig appConfig;

  BlocCore<dynamic> get blocCore => appConfig.blocCore();

  BlocResponsive get responsive =>
      blocCore.getBlocModule<BlocResponsive>(BlocResponsive.name);
  BlocLoading get loading =>
      blocCore.getBlocModule<BlocLoading>(BlocLoading.name);
  BlocMainMenuDrawer get mainMenu =>
      blocCore.getBlocModule<BlocMainMenuDrawer>(BlocMainMenuDrawer.name);
  BlocSecondaryMenuDrawer get secondaryMenu => blocCore
      .getBlocModule<BlocSecondaryMenuDrawer>(BlocSecondaryMenuDrawer.name);
  BlocTheme get theme => blocCore.getBlocModule<BlocTheme>(BlocTheme.name);
  BlocNavigator get navigator =>
      blocCore.getBlocModule<BlocNavigator>(BlocNavigator.name);
  BlocOnboarding get onboarding =>
      blocCore.getBlocModule<BlocOnboarding>(BlocOnboarding.name);
  BlocUserNotifications get blocUserNotifications =>
      blocCore.getBlocModule(BlocUserNotifications.name);

  FutureOr<void> dispose() {
    blocCore.dispose();
  }
}
