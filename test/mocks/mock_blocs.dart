import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

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
  MockBlocOnboarding();
  static String get name => BlocOnboarding.name;
}

class MockBlocNavigator extends BlocNavigator {
  MockBlocNavigator(super.pageManager);
  static String get name => BlocNavigator.name;
}
