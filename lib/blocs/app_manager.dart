import 'dart:async';

import '../jocaaguraarchetype.dart';

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
