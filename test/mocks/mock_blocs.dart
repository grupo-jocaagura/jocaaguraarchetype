import 'package:jocaaguraarchetype/blocs/bloc_loading.dart';
import 'package:jocaaguraarchetype/blocs/bloc_main_menu_drawer.dart';
import 'package:jocaaguraarchetype/blocs/bloc_navigator.dart';
import 'package:jocaaguraarchetype/blocs/bloc_onboarding.dart';
import 'package:jocaaguraarchetype/blocs/bloc_responsive.dart';
import 'package:jocaaguraarchetype/blocs/bloc_secondary_menu.dart';
import 'package:jocaaguraarchetype/blocs/bloc_theme.dart';
import 'package:jocaaguraarchetype/blocs/bloc_user_notifications.dart';

class MockBlocTheme extends BlocTheme {
  MockBlocTheme(super.providerTheme);
  static String get name => BlocTheme.name;
}

class MockBlocUserNotifications extends BlocUserNotifications {
  static String get name => BlocUserNotifications.name;
}

class MockBlocLoading extends BlocLoading {
  static String get name => BlocLoading.name;
}

class MockBlocMainMenuDrawer extends BlocMainMenuDrawer {
  static String get name => BlocMainMenuDrawer.name;
}

class MockBlocSecondaryMenuDrawer extends BlocSecondaryMenuDrawer {
  static String get name => BlocSecondaryMenuDrawer.name;
}

class MockBlocResponsive extends BlocResponsive {
  static String get name => BlocResponsive.name;
}

class MockBlocOnboarding extends BlocOnboarding {
  MockBlocOnboarding(super.blocOnboardingList);
  static String get name => BlocOnboarding.name;
}

class MockBlocNavigator extends BlocNavigator {
  MockBlocNavigator(super.pageManager);
  static String get name => BlocNavigator.name;
}
