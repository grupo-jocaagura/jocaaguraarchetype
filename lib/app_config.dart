import 'package:jocaagura_domain/jocaagura_domain.dart';

import 'jocaaguraarchetype.dart';

class AppConfig {
  const AppConfig({
    required this.blocTheme,
    required this.blocUserNotifications,
    required this.blocLoading,
    required this.blocMainMenuDrawer,
    required this.blocSecondaryMenuDrawer,
    required this.blocResponsive,
    required this.blocOnboarding,
    required this.blocNavigator,
    this.blocModuleList = const <String, BlocModule>{},
  });
  final BlocTheme blocTheme;
  final BlocUserNotifications blocUserNotifications;
  final BlocLoading blocLoading;
  final BlocMainMenuDrawer blocMainMenuDrawer;
  final BlocSecondaryMenuDrawer blocSecondaryMenuDrawer;
  final BlocResponsive blocResponsive;
  final BlocOnboarding blocOnboarding;
  final BlocNavigator blocNavigator;
  final Map<String, BlocModule> blocModuleList;

  BlocCore<dynamic> blocCore() {
    return BlocCore<dynamic>(<String, BlocModule>{
      BlocTheme.name: blocTheme,
      BlocNavigator.name: blocNavigator,
      BlocOnboarding.name: blocOnboarding,
      BlocResponsive.name: blocResponsive,
      BlocMainMenuDrawer.name: blocMainMenuDrawer,
      BlocSecondaryMenuDrawer.name: blocSecondaryMenuDrawer,
      BlocLoading.name: blocLoading,
      BlocUserNotifications.name: blocUserNotifications,
      ...blocModuleList,
    });
  }
}
