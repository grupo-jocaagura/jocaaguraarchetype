import 'blocs/bloc_loading.dart';
import 'blocs/bloc_main_menu.dart';
import 'blocs/bloc_navigator.dart';
import 'blocs/bloc_onboarding.dart';
import 'blocs/bloc_responsive.dart';
import 'blocs/bloc_secondary_menu.dart';
import 'blocs/bloc_theme.dart';
import 'blocs/bloc_user_notifications.dart';
import 'entities/entity_bloc.dart';

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
  });
  final BlocTheme blocTheme;
  final BlocUserNotifications blocUserNotifications;
  final BlocLoading blocLoading;
  final BlocMainMenuDrawer blocMainMenuDrawer;
  final BlocSecondaryMenuDrawer blocSecondaryMenuDrawer;
  final BlocResponsive blocResponsive;
  final BlocOnboarding blocOnboarding;
  final BlocNavigator blocNavigator;

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
    });
  }
}
