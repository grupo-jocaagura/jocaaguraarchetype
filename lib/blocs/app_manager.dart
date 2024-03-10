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

  BlocCore<dynamic> get _blocCore => appConfig.blocCore();

  BlocResponsive get responsive =>
      _blocCore.getBlocModule<BlocResponsive>(BlocResponsive.name);
  BlocLoading get loading =>
      _blocCore.getBlocModule<BlocLoading>(BlocLoading.name);
  BlocMainMenuDrawer get mainMenu =>
      _blocCore.getBlocModule<BlocMainMenuDrawer>(BlocMainMenuDrawer.name);
  BlocSecondaryMenuDrawer get secondaryMenu => _blocCore
      .getBlocModule<BlocSecondaryMenuDrawer>(BlocSecondaryMenuDrawer.name);
  BlocTheme get theme => _blocCore.getBlocModule<BlocTheme>(BlocTheme.name);
  BlocNavigator get navigator =>
      _blocCore.getBlocModule<BlocNavigator>(BlocNavigator.name);
  BlocOnboarding get onboarding =>
      _blocCore.getBlocModule<BlocOnboarding>(BlocOnboarding.name);
  BlocUserNotifications get blocUserNotifications =>
      _blocCore.getBlocModule(BlocUserNotifications.name);

  FutureOr<void> dispose() {
    _blocCore.dispose();
  }
}
